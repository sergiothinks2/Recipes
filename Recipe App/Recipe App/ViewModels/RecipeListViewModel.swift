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
    @Published private(set) var isEmpty = false
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchRecipes(forceRefresh: Bool = false) async {
        isLoading = true
        error = nil
        isEmpty = false
        
        if forceRefresh {
            await RecipeCache.shared.clearCache()
        }
        
        do {
            let fetchedRecipes = try await networkService.fetchRecipes()
            
            // Handle empty state
            if fetchedRecipes.isEmpty {
                isEmpty = true
                recipes = []
            } else {
                recipes = fetchedRecipes
            }
            error = nil
        } catch let error as NetworkError {
            self.error = error
            // Clear recipes on error as per requirement
            recipes = []
        } catch {
            self.error = .serverError(error)
            recipes = []
        }
        
        isLoading = false
    }
}
