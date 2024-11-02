//
//  RecipeListViewModel.swift
//  Recipe App
//
//  Created by Sergio Rodriguez on 11/2/24.
//

import SwiftUI

@MainActor
class RecipeListViewModel: ObservableObject {
    @Published private(set) var recipes: [Recipe] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: NetworkError?

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func fetchRecipes(forceRefresh: Bool = false) async {
        isLoading = true
        error = nil

        if forceRefresh {
            await RecipeCache.shared.clearCache()
        }

        do {
            recipes = try await networkService.fetchRecipes()
        } catch let error as NetworkError {
            self.error = error
        } catch {
            self.error = .serverError(error)
        }

        isLoading = false
    }
}
