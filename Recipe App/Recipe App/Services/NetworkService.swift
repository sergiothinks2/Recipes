//
//  NetworkService.swift
//  Recipe App
//
//  Created by Sergio Rodriguez on 11/1/24.
//

import Foundation

// MARK: - NetworkError
/// Represents various networking and data handling errors that can occur during API requests.
///
/// This enum provides specific error cases for different failure scenarios in the networking layer,
/// with user-friendly localized descriptions for each error type.
enum NetworkError: LocalizedError {
    /// Indicates the URL string couldn't be converted to a valid URL
    case invalidURL
    /// Indicates the server response wasn't in the expected format
    case invalidResponse
    /// Indicates a non-success HTTP status code, including the specific code
    case httpError(Int)
    /// Indicates failure to decode the JSON response into the expected model
    case decodingError(Error)
    /// Indicates a general network or server communication error
    case serverError(Error)

    /// Provides user-friendly error messages for each error case
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "Server error (Code: \(code))"
        case .decodingError(_):
            return "Unable to load recipes. Please try again later."
        case .serverError(_):
            return
                "Unable to connect to server. Please check your internet connection."
        }
    }
}

// MARK: - NetworkService Protocol
/// Defines the contract for fetching recipes from the network.
///
/// This protocol allows for easy substitution of the network service implementation,
/// facilitating testing and enabling alternative implementations if needed.
protocol NetworkServiceProtocol {
    /// Fetches the list of recipes from the network or cache.
    ///
    /// - Returns: An array of Recipe objects
    /// - Throws: NetworkError if the fetch operation fails
    func fetchRecipes() async throws -> [Recipe]
}

// MARK: - Network Service Implementation
/// Concrete implementation of the NetworkServiceProtocol for fetching recipes.
///
/// This service handles:
/// - Memory caching of recipes
/// - Network requests to fetch recipe data
/// - JSON decoding
/// - Error handling
///
/// Example usage:
/// ```swift
/// let service = NetworkService()
/// do {
///     let recipes = try await service.fetchRecipes()
///     // Handle successful response
/// } catch {
///     // Handle error
/// }
/// ```
final class NetworkService: NetworkServiceProtocol {
    /// The base URL for the recipes API endpoint
    private let baseURL = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"

    /// Reference to the shared recipe cache for in-memory caching
    private let cache = RecipeCache.shared

    /// Fetches recipes from either the cache or network.
    ///
    /// The method follows this process:
    /// 1. Checks for cached recipes and returns them if available
    /// 2. If no cache exists, makes a network request
    /// 3. Validates the HTTP response
    /// 4. Decodes the JSON response
    /// 5. Caches the new recipes
    ///
    /// - Returns: An array of Recipe objects
    /// - Throws: NetworkError for various failure scenarios:
    ///   - .invalidURL if the URL is malformed
    ///   - .invalidResponse for non-HTTP responses
    ///   - .httpError for non-200 status codes
    ///   - .decodingError if JSON parsing fails
    ///   - .serverError for other network failures
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
            let recipesResponse = try JSONDecoder().decode(
                RecipesResponse.self, from: data)
            // Cache the recipes in memory
            await cache.saveRecipes(recipesResponse.recipes)
            return recipesResponse.recipes
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}

// MARK: - Mock Network Service for Testing/Preview
#if DEBUG
    /// A mock implementation of NetworkServiceProtocol for testing and previews.
    ///
    /// This mock service allows for:
    /// - Controlled testing of success scenarios with custom recipe data
    /// - Testing of error handling by forcing failure cases
    /// - SwiftUI preview support with sample data
    class MockNetworkService: NetworkServiceProtocol {
        /// The recipes to return when fetchRecipes is called
        var mockRecipes: [Recipe]

        /// Flag to simulate a network failure when true
        var shouldFail = false

        /// Creates a new mock network service.
        ///
        /// - Parameters:
        ///   - mockRecipes: The recipes to return on successful fetch
        ///   - shouldFail: Whether the service should simulate a failure
        init(
            mockRecipes: [Recipe] = Recipe.sampleRecipes,
            shouldFail: Bool = false
        ) {
            self.mockRecipes = mockRecipes
            self.shouldFail = shouldFail
        }

        func fetchRecipes() async throws -> [Recipe] {
            if shouldFail {
                throw NetworkError.serverError(
                    NSError(domain: "Mock", code: -1))
            }
            return mockRecipes
        }
    }
#endif
