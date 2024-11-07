//
//  RecipeListView.swift
//  Recipe App
//
//  Created by Sergio Rodriguez on 11/2/24.
//

import SwiftUI

/// The main view for displaying the list of recipes.
///
/// This view implements a responsive UI that handles different states:
/// - Loading state with progress indicator
/// - Empty state with descriptive message
/// - Error state with retry option
/// - Content state showing the recipe list
///
/// The view uses SwiftUI's built-in navigation and supports pull-to-refresh.
struct RecipeListView: View {
    /// View model that manages the state and business logic
    @StateObject private var viewModel = RecipeListViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.recipes.isEmpty {
                    ProgressView("Loading recipes...")
                } else if viewModel.isEmpty {
                    EmptyStateView(
                        title: "No Recipes Available",
                        message: "Check back later for delicious recipes!",
                        systemImage: "fork.knife.circle"
                    )
                } else if viewModel.error != nil {
                    ErrorStateView(
                        error: viewModel.error?.localizedDescription
                            ?? "Unknown error",
                        retryAction: {
                            Task {
                                await viewModel.fetchRecipes(forceRefresh: true)
                            }
                        }
                    )
                } else {
                    RecipeListContent(
                        recipes: viewModel.recipes,
                        onRefresh: {
                            await viewModel.fetchRecipes(forceRefresh: true)
                        }
                    )
                }
            }
            .navigationTitle("Recipes")
        }
        .task {
            await viewModel.fetchRecipes()
        }
    }
}

/// A view that displays the list of recipes with pull-to-refresh capability.
///
/// This view is extracted from the main view for better organization and reusability.
struct RecipeListContent: View {
    /// The recipes to display in the list
    let recipes: [Recipe]

    /// Closure to be called when the user initiates a refresh
    let onRefresh: () async -> Void

    var body: some View {
        List(recipes) { recipe in
            RecipeRowView(recipe: recipe)
        }
        .refreshable {
            await onRefresh()
        }
    }
}

/// A reusable view for displaying empty state messages.
///
/// This view presents a consistent empty state UI with:
/// - A customizable system image
/// - A title
/// - A descriptive message
struct EmptyStateView: View {
    /// The main title text
    let title: String

    /// A longer descriptive message
    let message: String

    /// The SF Symbol name to use for the icon
    let systemImage: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text(title)
                .font(.title2)
                .fontWeight(.medium)

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

/// A reusable view for displaying error states with a retry option.
///
/// This view presents a consistent error UI with:
/// - An warning icon
/// - An error message
/// - A retry button
struct ErrorStateView: View {
    /// The error message to display
    let error: String

    /// Action to perform when the retry button is tapped
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Unable to Load Recipes")
                .font(.title2)
                .fontWeight(.medium)

            Text(error)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: retryAction) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

/// A view representing a single row in the recipe list.
///
/// This view displays:
/// - A thumbnail image with loading states
/// - Recipe name
/// - Cuisine type
/// - Navigation link to recipe details
struct RecipeRowView: View {
    /// The recipe to display in this row
    let recipe: Recipe

    var body: some View {
        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
            HStack {
                CachedAsyncImage(url: URL(string: recipe.photoURLSmall ?? "")) {
                    phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                        .font(.headline)
                    Text(recipe.cuisine)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

/// Previews for the recipe list view.
struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeListView()
    }
}
