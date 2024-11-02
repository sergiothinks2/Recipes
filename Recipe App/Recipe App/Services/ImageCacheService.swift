//
//  ImageCacheService.swift
//  Recipe App
//
//  Created by Sergio Rodriguez on 11/2/24.
//

import SwiftUI

// MARK: - Image Cache Service
actor ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        try? fileManager.createDirectory(
            at: cacheDirectory, withIntermediateDirectories: true)
    }

    func image(for url: URL) async throws -> UIImage {
        // Check memory cache first
        let key = url.absoluteString as NSString
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }

        // Check disk cache
        let imagePath = cacheDirectory.appendingPathComponent(
            key.hash.description)
        if let data = try? Data(contentsOf: imagePath),
            let image = UIImage(data: data)
        {
            cache.setObject(image, forKey: key)
            return image
        }

        // Download and cache if not found
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw NetworkError.invalidResponse
        }

        // Save to memory and disk
        cache.setObject(image, forKey: key)
        try? data.write(to: imagePath)

        return image
    }

    func clearCache() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(
            at: cacheDirectory, withIntermediateDirectories: true)
    }
}
