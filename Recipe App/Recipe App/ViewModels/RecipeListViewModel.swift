//
//  RecipeListViewModel.swift
//  Recipe App
//
//  Created by Sergio Rodriguez on 11/2/24.
//

import SwiftUI

/// A view model that manages the state and business logic for the recipe list view.
///
/// This class follows the MVVM pattern and handles:
/// - Fetching recipes from the network service
/// - Managing loading and error states
/// - Handling empty states
/// - Coordinating cache refreshes
///
/// Example usage:
/// ```swift
/// class RecipeListView: View {
///     @StateObject private var viewModel = RecipeListViewModel()
///
///     var body: some View {
///         List(viewModel.recipes) { recipe in
///             RecipeRowView(recipe: recipe)
///         }
///         .task {
///             await viewModel.fetchRecipes()
///         }
///     }
/// }
/// ```
@MainActor
class RecipeListViewModel: ObservableObject {
    /// The current list of recipes to display
    @Published private(set) var recipes: [Recipe] = []

    /// Indicates whether a network request is in progress
    @Published private(set) var isLoading = false

    /// The current error state, if any
    @Published private(set) var error: NetworkError?

    /// Indicates whether the recipes list is empty after a successful fetch
    @Published private(set) var isEmpty = false

    /// The network service used to fetch recipes
    private let networkService: NetworkServiceProtocol

    /// Creates a new recipe list view model.
    ///
    /// - Parameter networkService: The service used to fetch recipes. Defaults to the standard implementation
    ///                            but can be replaced with a mock for testing.
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    /// Fetches recipes from the network service or cache.
    ///
    /// This method manages the entire fetch operation lifecycle:
    /// 1. Updates loading state
    /// 2. Clears any existing errors
    /// 3. Fetches recipes from network/cache
    /// 4. Updates the view state based on the result
    ///
    /// State updates:
    /// - Updates `isLoading` during the fetch
    /// - Updates `error` if the fetch fails
    /// - Updates `isEmpty` if no recipes are returned
    /// - Updates `recipes` with the fetched data
    ///
    /// - Parameter forceRefresh: When true, clears the cache before fetching.
    ///                          Use this for pull-to-refresh functionality.
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
