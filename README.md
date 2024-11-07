# Recipes
Simple list app to show user recipes

### Steps to Run the App

1. Clone the repository
2. Open Recipe App.xcodeproj in Xcode 15.0 or later
3. Set deployment target to iOS 16.0+
4. Build and run the app on simulator or device

Note: No additional setup or dependencies are required as the project uses only native frameworks.

### Focus Areas: What specific areas of the project did you prioritize? Why did you choose to focus on these areas?


Swift Concurrency:
Implemented async/await throughout the app
Used actors for thread-safe caching (ImageCache and RecipeCache)
Proper MainActor usage in the ViewModel


Efficient Resource Management:
Two-level image caching (memory and disk) for optimal performance
Memory-only recipe caching as per requirements
Load images on-demand with CachedAsyncImage component


Clean Architecture and Testing:
MVVM architecture with clear separation of concerns
Protocol-based networking for testability
Created unit tests with mock services
Reusable components (EmptyStateView, ErrorStateView)


User Experience:
Responsive UI with loading states
Error handling
Pull-to-refresh functionality
Smooth image loading transitions

### Time Spent: Approximately how long did you spend working on this project? How did you allocate your time?

I spent just over 5 hours on the project.
I spent some time at the beginning with project setup and how I wanted to implement MVVM architecture.
Then I spent the majority of my time on developing mostly in this order: the Model, the ViewModel, the Views, The Caching services, Unit Tests.
Spent the last part going over my project, triple checking the requirements, and adding comments.

### Trade-offs and Decisions: Did you make any significant trade-offs in your approach?

WebView for Recipe Details:
Chose to use WKWebView to display recipe content directly from source URLs
Trade-off: This approach is simpler to implement but depends on external websites' availability and formatting (annoying cookie banners)
Alternative would be parsing and displaying structured recipe data, but would require more complex API and UI

Image Caching Implementation:
Built custom image caching instead of using third-party libraries
Trade-off: More code to maintain but better control over caching behavior and no external dependencies
Custom implementation allows specific optimizations for our use case

Memory-Only Recipe Cache:
Implemented a simple actor-based memory cache for recipes
Trade-off: Data is lost on app termination but meets the requirement of not persisting recipe data

### Weakest Part of the Project: What do you think is the weakest part of your project?

Error Handling Granularity:
Current error handling is basic and could be more specific
Could add retry logic
Could add better offline handling

Basic Design:
Project is out of the box SwiftUI and UI can be much prettier

### External Code and Dependencies: Did you use any external code, libraries, or dependencies?

Native Frameworks Used:
SwiftUI for UI
WKWebView for web content
UIKit for system interactions (opening URLs)
URLSession for networking
XCTest for testing

No Third-Party Dependencies:
Chose to implement custom solutions instead of using libraries
Makes the project easier to maintain and review

### Additional Information: Is there anything else we should know? Feel free to share any insights or constraints you encountered.

Future Improvements:
Add sorting and filtering options for recipes
Implement search functionality
Add accessibility features
Implement offline mode with proper caching strategy

The project demonstrates modern iOS development practices while maintaining simplicity and meeting all core requirements. It's structured to be maintainable and extensible for future enhancements.
