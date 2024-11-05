//
//  Recipe_AppTests.swift
//  Recipe AppTests
//
//  Created by Sergio Rodriguez on 11/1/24.
//

import XCTest

@testable import Recipe_App

final class RecipeListViewModelTests: XCTestCase {
    var viewModel: RecipeListViewModel!
    var mockNetworkService: MockNetworkService!

    override func setUp() async throws {
        try await super.setUp()
        mockNetworkService = MockNetworkService()
        await MainActor.run {
            viewModel = RecipeListViewModel(networkService: mockNetworkService)
        }
    }

    override func tearDown() async throws {
        try await super.tearDown()
        await MainActor.run {
            viewModel = nil
        }
        mockNetworkService = nil
    }

    @MainActor
    func testFetchRecipesSuccess() async throws {
        // Given
        let expectedRecipes = [
            Recipe(
                id: "1", name: "Test Recipe", cuisine: "Italian",
                photoURLSmall: nil, photoURLLarge: nil,
                sourceURL: nil, youtubeURL: nil)
        ]
        mockNetworkService.mockRecipes = expectedRecipes
        mockNetworkService.scenario = .success

        // When
        await viewModel.fetchRecipes()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertEqual(viewModel.recipes.count, expectedRecipes.count)
        XCTAssertEqual(viewModel.recipes.first?.id, expectedRecipes.first?.id)
    }

    @MainActor
    func testFetchRecipesEmptyData() async throws {
        // Given
        mockNetworkService.mockRecipes = []
        mockNetworkService.scenario = .empty

        // When
        await viewModel.fetchRecipes()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertTrue(viewModel.recipes.isEmpty)
    }

    @MainActor
    func testFetchRecipesMalformedData() async throws {
        // Given
        mockNetworkService.scenario = .malformed

        // When
        await viewModel.fetchRecipes()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.error)
        if case .decodingError(_) = viewModel.error {
            // Success - we got the expected error type
        } else {
            XCTFail(
                "Expected decodingError but got \(String(describing: viewModel.error))"
            )
        }
    }

    @MainActor
    func testFetchRecipesNetworkError() async throws {
        // Given
        mockNetworkService.scenario = .networkError

        // When
        await viewModel.fetchRecipes()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.error)
        if case .serverError(_) = viewModel.error {
            // Success - we got the expected error type
        } else {
            XCTFail(
                "Expected serverError but got \(String(describing: viewModel.error))"
            )
        }
    }
}

// Enhanced Mock Network Service
class MockNetworkService: NetworkServiceProtocol {
    enum Scenario {
        case success
        case empty
        case malformed
        case networkError
    }

    var mockRecipes: [Recipe] = []
    var scenario: Scenario = .success

    init(
        mockRecipes: [Recipe] = Recipe.sampleRecipes,
        scenario: Scenario = .success
    ) {
        self.mockRecipes = mockRecipes
        self.scenario = scenario
    }

    func fetchRecipes() async throws -> [Recipe] {
        switch scenario {
        case .success:
            return mockRecipes

        case .empty:
            return []

        case .malformed:
            throw NetworkError.decodingError(
                NSError(
                    domain: "MockError", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Malformed data"])
            )

        case .networkError:
            throw NetworkError.serverError(
                NSError(
                    domain: "MockError", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Network error"])
            )
        }
    }
}
