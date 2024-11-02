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
    
    func fetchRecipes() async throws -> [Recipe] {
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
            return recipesResponse.recipes
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}

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
