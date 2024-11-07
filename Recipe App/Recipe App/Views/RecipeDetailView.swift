//
//  RecipeDetailView.swift
//  Recipe App
//
//  Created by Sergio Rodriguez on 11/2/24.
//

import SwiftUI
import UIKit
import WebKit

/// A view that displays detailed information about a recipe.
///
/// This view provides:
/// - Recipe title
/// - Web content from the recipe's source URL (if available)
/// - YouTube video link (if available)
/// - Fallback content for unavailable recipes
///
/// The view handles different states of content availability and loading states
/// for the web content.
struct RecipeDetailView: View {
    /// The recipe to display details for
    let recipe: Recipe

    /// Tracks the loading state of the web content
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text(recipe.name)
                    .font(.title)
                    .bold()
                    .padding(.horizontal)

                // Recipe URL Content
                VStack(alignment: .leading) {
                    if let sourceURL = recipe.sourceURL,
                        let url = URL(string: sourceURL)
                    {
                        ZStack {
                            WebView(url: url, isLoading: $isLoading)
                                .frame(minHeight: 600, maxHeight: 800)

                            if isLoading {
                                VStack {
                                    ProgressView()
                                        .scaleEffect(1.5)
                                    Text("Loading recipe...")
                                        .foregroundColor(.secondary)
                                        .padding(.top)
                                }
                                .frame(
                                    maxWidth: .infinity, maxHeight: .infinity
                                )
                                .background(Color(.systemBackground))
                            }
                        }
                    } else {
                        // Unavailable content view
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)

                            Text("Recipe Not Available")
                                .font(.title2)
                                .foregroundColor(.primary)

                            Text(
                                "This recipe doesn't have detailed instructions."
                            )
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 400)
                        .background(Color(.systemBackground))
                    }
                }

                // YouTube Button
                if let youtubeURL = recipe.youtubeURL,
                    let url = URL(string: youtubeURL)
                {
                    HStack {
                        Spacer()
                        Button(action: {
                            UIApplication.shared.open(url)
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Watch on YouTube")
                            }
                            .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        Spacer()
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// A SwiftUI wrapper around WKWebView for displaying web content.
///
/// This view provides a bridge between UIKit's WKWebView and SwiftUI,
/// handling web content loading and state management through a coordinator pattern.
///
/// Example usage:
/// ```swift
/// WebView(url: recipeURL, isLoading: $isLoading)
///     .frame(height: 600)
/// ```
struct WebView: UIViewRepresentable {
    /// The URL of the web content to load
    let url: URL

    /// Binding to track the loading state of the web content
    @Binding var isLoading: Bool

    /// Creates the coordinator to handle the web view's navigation delegate callbacks
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    /// Creates and configures the WKWebView instance
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    /// Required by UIViewRepresentable but not used in this implementation
    func updateUIView(_ webView: WKWebView, context: Context) {}

    /// Coordinator class that handles WKWebView navigation delegate callbacks
    ///
    /// This class manages the communication between the WKWebView and our SwiftUI view,
    /// primarily handling loading state updates.
    class Coordinator: NSObject, WKNavigationDelegate {
        /// Reference to the parent WebView
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        /// Called when the web content finishes loading successfully
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
        {
            parent.isLoading = false
        }

        /// Called when the web content fails to load
        func webView(
            _ webView: WKWebView, didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            parent.isLoading = false
        }
    }
}
