//
//  RecipeCacheService.swift
//  Recipe App
//
//  Created by Sergio Rodriguez on 11/2/24.
//

import Foundation

// MARK: - Recipe Cache Service (Memory Only)
/// An actor-based service that provides in-memory caching for recipes.
///
/// `RecipeCache` is designed to be a lightweight, memory-only cache for recipe data.
/// It uses Swift's actor model to ensure thread-safe access to the cached data
/// without the overhead of disk persistence.
///
/// Example usage:
/// ```swift
/// // Save recipes to cache
/// await RecipeCache.shared.saveRecipes(recipes)
///
/// // Retrieve cached recipes
/// if let recipes = await RecipeCache.shared.getCachedRecipes() {
///     // Use cached recipes
/// }
/// ```
///
/// Important: The cache is memory-only and will be cleared when the app terminates.
/// This aligns with the requirement to not persist recipe data to disk.
actor RecipeCache {
    /// Shared singleton instance of the recipe cache
    static let shared = RecipeCache()

    /// The currently cached recipes, if any
    private var cachedRecipes: [Recipe]?

    /// The timestamp of the last successful cache update
    private var lastFetchTime: Date?

    /// Saves a new set of recipes to the cache.
    ///
    /// This method replaces any existing cached recipes and updates
    /// the last fetch timestamp.
    ///
    /// - Parameter recipes: The array of recipes to cache
    func saveRecipes(_ recipes: [Recipe]) {
        cachedRecipes = recipes
        lastFetchTime = Date()
    }

    /// Retrieves the currently cached recipes, if any.
    ///
    /// - Returns: An array of cached Recipe objects, or nil if no cache exists
    func getCachedRecipes() -> [Recipe]? {
        cachedRecipes
    }

    /// Clears all cached data.
    ///
    /// This method removes both the cached recipes and the last fetch timestamp.
    /// Use this when you need to force a fresh fetch of recipe data.
    func clearCache() {
        cachedRecipes = nil
        lastFetchTime = nil
    }
}
