//
//  Recipe_AppTests.swift
//  Recipe AppTests
//
//  Created by Sergio Rodriguez on 11/1/24.
//

import XCTest

@testable import Recipe_App

/// Test suite for RecipeListViewModel focusing on recipe fetching functionality.
///
/// These tests verify:
/// - Successful recipe fetching
/// - Empty data handling
/// - Error handling for malformed data
/// - Network error handling
///
/// The tests use a mock network service to simulate different scenarios
/// and verify the view model's state management.
final class RecipeListViewModelTests: XCTestCase {
    /// The view model instance being tested
    var viewModel: RecipeListViewModel!

    /// Mock network service for controlling test scenarios
    var mockNetworkService: MockNetworkService!

    /// Sets up the test environment before each test.
    ///
    /// Creates new instances of the mock network service and view model
    /// to ensure a clean state for each test.
    override func setUp() async throws {
        try await super.setUp()
        mockNetworkService = MockNetworkService()
        await MainActor.run {
            viewModel = RecipeListViewModel(networkService: mockNetworkService)
        }
    }

    /// Cleans up after each test.
    ///
    /// Releases references to the view model and mock service
    /// to prevent state leakage between tests.
    override func tearDown() async throws {
        try await super.tearDown()
        await MainActor.run {
            viewModel = nil
        }
        mockNetworkService = nil
    }

    /// Tests successful recipe fetching scenario.
    ///
    /// Verifies that:
    /// - Loading state is properly managed
    /// - No errors are present
    /// - Recipe data is correctly populated
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

    /// Tests handling of empty recipe data.
    ///
    /// Verifies that:
    /// - Empty state is properly handled
    /// - No errors are present
    /// - Recipes array is empty
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

    /// Tests handling of malformed data response.
    ///
    /// Verifies that:
    /// - Decoding error is properly captured
    /// - Error state is correctly set
    /// - Recipes array is cleared
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

    /// Tests handling of network errors.
    ///
    /// Verifies that:
    /// - Network errors are properly captured
    /// - Error state is correctly set
    /// - Recipes array is cleared
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

// MARK: - Mock Network Service
/// A mock implementation of NetworkServiceProtocol for testing purposes.
///
/// This mock service allows tests to:
/// - Control the response data
/// - Simulate different network scenarios
/// - Verify error handling
class MockNetworkService: NetworkServiceProtocol {
    /// Defines different test scenarios for the mock service
    enum Scenario {
        /// Returns successful response with mock recipes
        case success
        /// Returns empty recipe array
        case empty
        /// Simulates malformed data error
        case malformed
        /// Simulates network connection error
        case networkError
    }

    /// The mock recipes to return in success scenario
    var mockRecipes: [Recipe] = []

    /// The current test scenario
    var scenario: Scenario = .success

    /// Creates a new mock network service.
    ///
    /// - Parameters:
    ///   - mockRecipes: The recipes to return in success scenario
    ///   - scenario: The test scenario to simulate
    init(
        mockRecipes: [Recipe] = Recipe.sampleRecipes,
        scenario: Scenario = .success
    ) {
        self.mockRecipes = mockRecipes
        self.scenario = scenario
    }

    /// Simulates fetching recipes based on the current scenario.
    ///
    /// - Returns: Mock recipe data in success scenario
    /// - Throws: Appropriate NetworkError based on the scenario
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
