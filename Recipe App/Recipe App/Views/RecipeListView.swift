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
            Group {
                if viewModel.isLoading && viewModel.recipes.isEmpty {
                    ProgressView()
                } else {
                    List(viewModel.recipes) { recipe in
                        RecipeRowView(recipe: recipe)
                    }
                    .refreshable {
                        await viewModel.fetchRecipes(forceRefresh: true)
                    }
                }
            }
            .navigationTitle("Recipes")
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("Retry") {
                    Task {
                        await viewModel.fetchRecipes(forceRefresh: true)
                    }
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "")
            }
        }
        .task {
            await viewModel.fetchRecipes()
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
