//
//  Recipe.swift
//  Recipe App
//
//  Created by Sergio Rodriguez on 11/1/24.
//

import Foundation

struct Recipe: Codable, Identifiable {
    let id: String
    let name: String
    let cuisine: String
    let photoURLSmall: String?
    let photoURLLarge: String?
    let sourceURL: String?
    let youtubeURL: String?

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

// Root response
struct RecipesResponse: Codable {
    let recipes: [Recipe]
}

extension Recipe {
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

#if DEBUG
    extension Recipe {
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
