//
//  Recipe.swift
//  Recipe App
//
//  Created by Sergio Rodriguez on 11/1/24.
//

import Foundation

/// A model representing a cooking recipe with its associated metadata and media links.
///
/// The `Recipe` model serves as the core data structure for the Recipe App, containing
/// all necessary information to display and interact with a recipe, including:
/// - Basic information (name, cuisine type)
/// - Media content (photos in different sizes)
/// - External links (source recipe and video content)
struct Recipe: Codable, Identifiable {
    /// Unique identifier for the recipe, mapped from "uuid" in the API response
    let id: String

    /// The display name of the recipe
    let name: String

    /// The type of cuisine this recipe belongs to (e.g., "Italian", "Japanese")
    let cuisine: String

    /// URL for the recipe's thumbnail image, optimized for list views
    let photoURLSmall: String?

    /// URL for the recipe's full-size image, suitable for detailed views
    let photoURLLarge: String?

    /// URL linking to the full recipe instructions on the source website
    let sourceURL: String?

    /// URL linking to a video demonstration of the recipe on YouTube
    let youtubeURL: String?

    /// Coding keys that map the model properties to their corresponding JSON keys
    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name
        case cuisine
        case photoURLSmall = "photo_url_small"
        case photoURLLarge = "photo_url_large"
        case sourceURL = "source_url"
        case youtubeURL = "youtube_url"
    }
}

/// A container structure for the API response that includes an array of recipes.
struct RecipesResponse: Codable {
    /// The collection of recipes returned by the API
    let recipes: [Recipe]
}

// MARK: - Sample Data
extension Recipe {
    /// A collection of sample recipes for use in previews and testing.
    ///
    /// These recipes represent different cuisines and contain example URLs
    /// for all optional fields to ensure proper layout in preview environments.
    static let sampleRecipes: [Recipe] = [
        Recipe(
            id: "1",
            name: "Spaghetti Carbonara",
            cuisine: "Italian",
            photoURLSmall: "https://example.com/carbonara-small.jpg",
            photoURLLarge: "https://example.com/carbonara-large.jpg",
            sourceURL: "https://example.com/carbonara-recipe",
            youtubeURL: "https://youtube.com/watch?v=carbonara"
        ),
        Recipe(
            id: "2",
            name: "Sushi Roll",
            cuisine: "Japanese",
            photoURLSmall: "https://example.com/sushi-small.jpg",
            photoURLLarge: "https://example.com/sushi-large.jpg",
            sourceURL: "https://example.com/sushi-recipe",
            youtubeURL: "https://youtube.com/watch?v=sushi"
        ),
        Recipe(
            id: "3",
            name: "Tacos al Pastor",
            cuisine: "Mexican",
            photoURLSmall: "https://example.com/tacos-small.jpg",
            photoURLLarge: "https://example.com/tacos-large.jpg",
            sourceURL: "https://example.com/tacos-recipe",
            youtubeURL: "https://youtube.com/watch?v=tacos"
        ),
    ]
}

// MARK: - Testing Utilities
#if DEBUG
    extension Recipe {
        /// Creates a mock recipe with customizable properties for testing purposes.
        ///
        /// This utility function allows for easy creation of Recipe instances
        /// during testing, with reasonable defaults for all properties.
        ///
        /// - Parameters:
        ///   - id: The unique identifier for the recipe. Defaults to "test-id"
        ///   - name: The name of the recipe. Defaults to "Test Recipe"
        ///   - cuisine: The cuisine type. Defaults to "Test Cuisine"
        ///   - photoURLSmall: Optional URL for the small photo. Defaults to nil
        ///   - photoURLLarge: Optional URL for the large photo. Defaults to nil
        ///   - sourceURL: Optional URL for the recipe source. Defaults to nil
        ///   - youtubeURL: Optional URL for the YouTube video. Defaults to nil
        /// - Returns: A Recipe instance with the specified properties
        static func mockRecipe(
            id: String = "test-id",
            name: String = "Test Recipe",
            cuisine: String = "Test Cuisine",
            photoURLSmall: String? = nil,
            photoURLLarge: String? = nil,
            sourceURL: String? = nil,
            youtubeURL: String? = nil
        ) -> Recipe {
            Recipe(
                id: id,
                name: name,
                cuisine: cuisine,
                photoURLSmall: photoURLSmall,
                photoURLLarge: photoURLLarge,
                sourceURL: sourceURL,
                youtubeURL: youtubeURL
            )
        }
    }
#endif
