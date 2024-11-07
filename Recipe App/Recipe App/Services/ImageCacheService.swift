//
//  ImageCacheService.swift
//  Recipe App
//
//  Created by Sergio Rodriguez on 11/2/24.
//

import SwiftUI

// MARK: - Image Cache Service
/// A concurrent image caching service that provides both memory and disk caching capabilities.
///
/// `ImageCache` is implemented as an actor to ensure thread-safe access to the cached images.
/// It implements a two-level caching strategy:
/// 1. Memory cache using `NSCache` for fast access to recently used images
/// 2. Disk cache in the app's cache directory for persistence across launches
///
/// Example usage:
/// ```swift
/// do {
///     let image = try await ImageCache.shared.image(for: imageURL)
///     // Use the cached image
/// } catch {
///     // Handle error
/// }
/// ```
actor ImageCache {
    /// Shared singleton instance of the image cache
    static let shared = ImageCache()

    /// In-memory cache for storing recently used images
    private let cache = NSCache<NSString, UIImage>()

    /// File manager instance for disk operations
    private let fileManager = FileManager.default

    /// URL for the disk cache directory where images are stored
    private let cacheDirectory: URL

    /// Initializes the image cache service and sets up the disk cache directory.
    ///
    /// Creates a dedicated directory named "ImageCache" in the app's cache directory
    /// where downloaded images will be stored persistently.
    init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        try? fileManager.createDirectory(
            at: cacheDirectory, withIntermediateDirectories: true)
    }

    /// Retrieves an image from cache or downloads it if not cached.
    ///
    /// This method implements a caching strategy that checks multiple locations in order:
    /// 1. Checks the memory cache for immediate access
    /// 2. Checks the disk cache if not found in memory
    /// 3. Downloads the image from the network if not found in either cache
    ///
    /// After downloading, the image is saved to both memory and disk caches for future access.
    ///
    /// - Parameter url: The URL of the image to retrieve
    /// - Returns: A UIImage instance
    /// - Throws: NetworkError if the image cannot be downloaded or is invalid
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

    /// Clears both memory and disk caches.
    ///
    /// This method:
    /// 1. Removes all objects from the memory cache
    /// 2. Deletes and recreates the disk cache directory
    ///
    /// Use this method when you need to free up memory/disk space or
    /// ensure fresh image downloads.
    func clearCache() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(
            at: cacheDirectory, withIntermediateDirectories: true)
    }
}
