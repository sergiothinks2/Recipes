//
//  RecipeDetailView.swift
//  Recipe App
//
//  Created by Sergio Rodriguez on 11/2/24.
//

import SwiftUI
import UIKit
import WebKit

struct RecipeDetailView: View {
    let recipe: Recipe

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
                        WebView(url: url)
                            .frame(height: 400)
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

// WebView using UIKit's WKWebView
struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}
