//
//  NetworkService.swift
//  Recipe App
//
//  Created by Sergio Rodriguez on 11/1/24.
//

import Foundation

// MARK: - NetworkError
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case serverError(Error)
}

// MARK: - NetworkService Protocol
protocol NetworkServiceProtocol {
    func fetchRecipes() async throws -> [Recipe]
}

// MARK: - Network Service Implementation
final class NetworkService: NetworkServiceProtocol {
    private let baseURL = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
    private let cache = RecipeCache.shared
    
    func fetchRecipes() async throws -> [Recipe] {
        // Return cached recipes if available
        if let cachedRecipes = await cache.getCachedRecipes() {
            return cachedRecipes
        }
        
        // Fetch new recipes
        guard let url = URL(string: baseURL) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }
        
        do {
            let recipesResponse = try JSONDecoder().decode(RecipesResponse.self, from: data)
            // Cache the recipes in memory
            await cache.saveRecipes(recipesResponse.recipes)
            return recipesResponse.recipes
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}

// MARK: - AsyncImage View with Caching
//struct CachedAsyncImage<Content: View>: View {
//    private let url: URL
//    private let scale: CGFloat
//    private let transaction: Transaction
//    private let content: (AsyncImagePhase) -> Content
//    
//    init(
//        url: URL,
//        scale: CGFloat = 1.0,
//        transaction: Transaction = Transaction(),
//        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
//    ) {
//        self.url = url
//        self.scale = scale
//        self.transaction = transaction
//        self.content = content
//    }
//    
//    var body: some View {
//        AsyncImage(
//            url: url,
//            scale: scale,
//            transaction: transaction
//        ) { phase in
//            content(phase)
//        }
//        .task {
//            // Prefetch and cache the image
//            try? await ImageCache.shared.image(for: url)
//        }
//    }
//}


// MARK: - Mock Network Service for Testing/Preview
// TODO: come back to fix this
//#if DEBUG
//class MockNetworkService: NetworkServiceProtocol {
//    var mockRecipes: [Recipe]
//    var shouldFail = false
//    
//    init(mockRecipes: [Recipe] = Recipe.sampleRecipes, shouldFail: Bool = false) {
//        self.mockRecipes = mockRecipes
//        self.shouldFail = shouldFail
//    }
//    
//    func fetchRecipes() async throws -> [Recipe] {
//        if shouldFail {
//            throw NetworkError.serverError(NSError(domain: "Mock", code: -1))
//        }
//        return mockRecipes
//    }
//}
//#endif
