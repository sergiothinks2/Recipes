//
//  RecipeListView.swift
//  Recipe App
//
//  Created by Sergio Rodriguez on 11/2/24.
//

import SwiftUI

struct RecipeListView: View {
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

// Split out the list content for cleaner organization
struct RecipeListContent: View {
    let recipes: [Recipe]
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
// Reusable empty state view
struct EmptyStateView: View {
    let title: String
    let message: String
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

// Reusable error state view
struct ErrorStateView: View {
    let error: String
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

// Row view for each recipe
struct RecipeRowView: View {
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

struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeListView()
    }
}
