//
//  RecipeCacheService.swift
//  Recipe App
//
//  Created by Sergio Rodriguez on 11/2/24.
//

import Foundation

// MARK: - Recipe Cache Service (Memory Only)
actor RecipeCache {
    static let shared = RecipeCache()

    private var cachedRecipes: [Recipe]?
    private var lastFetchTime: Date?

    func saveRecipes(_ recipes: [Recipe]) {
        cachedRecipes = recipes
        lastFetchTime = Date()
    }

    func getCachedRecipes() -> [Recipe]? {
        cachedRecipes
    }

    func clearCache() {
        cachedRecipes = nil
        lastFetchTime = nil
    }
}
