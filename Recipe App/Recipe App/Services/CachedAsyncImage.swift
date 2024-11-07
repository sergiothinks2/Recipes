//
//  CachedAsyncImage.swift
//  Recipe App
//
//  Created by Sergio Rodriguez on 11/4/24.
//

import SwiftUI

/// A SwiftUI view that asynchronously loads and displays an image from a URL with caching support.
///
/// `CachedAsyncImage` provides similar functionality to SwiftUI's built-in `AsyncImage`,
/// but adds disk and memory caching capabilities to improve performance and reduce network usage.
/// The view handles loading, success, and failure states through a phase-based approach.
///
/// Example usage with custom content:
/// ```swift
/// CachedAsyncImage(url: imageURL) { phase in
///     switch phase {
///     case .empty:
///         ProgressView()
///     case .success(let image):
///         image.resizable()
///              .aspectRatio(contentMode: .fit)
///     case .failure:
///         Image(systemName: "photo")
///     @unknown default:
///         EmptyView()
///     }
/// }
/// ```
struct CachedAsyncImage<Content: View>: View {
    /// The URL from which to load the image
    let url: URL?

    /// The scale to use for the image, defaults to 1.0
    let scale: CGFloat

    /// A closure that takes an AsyncImagePhase and returns a view to display
    let content: (AsyncImagePhase) -> Content

    /// The current phase of the async image loading process
    @State private var phase: AsyncImagePhase = .empty

    /// Creates a new cached async image view with custom content for each loading phase.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to load (optional)
    ///   - scale: The scale to use for the image, defaults to 1.0
    ///   - content: A closure that takes an AsyncImagePhase and returns a view to display
    init(
        url: URL?,
        scale: CGFloat = 1.0,
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.scale = scale
        self.content = content
    }

    var body: some View {
        content(phase)
            .task {
                await loadImage()
            }
    }

    /// Asynchronously loads the image from the provided URL using the ImageCache service.
    ///
    /// This function handles the image loading process and updates the phase accordingly:
    /// - Sets phase to .empty if URL is nil
    /// - Sets phase to .success with the loaded image on successful load
    /// - Sets phase to .failure with the error on failed load
    private func loadImage() async {
        guard let url = url else {
            phase = .empty
            return
        }

        do {
            let image = try await ImageCache.shared.image(for: url)
            withAnimation {
                phase = .success(Image(uiImage: image))
            }
        } catch {
            phase = .failure(error)
        }
    }
}

// MARK: - Convenience Initializer
extension CachedAsyncImage where Content == AnyView {
    /// A convenience initializer that provides default view implementations for each loading phase.
    ///
    /// This initializer simplifies the common use case where you want standard loading, success,
    /// and error views. It provides:
    /// - A progress view for the loading state
    /// - A resizable, aspect-fit image for the success state
    /// - A "photo" system image for the failure state
    ///
    /// Example usage:
    /// ```swift
    /// CachedAsyncImage(url: imageURL)
    ///     .frame(width: 100, height: 100)
    /// ```
    init(
        url: URL?,
        scale: CGFloat = 1.0
    ) {
        self.init(url: url, scale: scale) { phase in
            let view: AnyView

            switch phase {
            case .empty:
                view = AnyView(
                    ProgressView()
                        .frame(minWidth: 44, minHeight: 44)
                )
            case .success(let image):
                view = AnyView(
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                )
            case .failure:
                view = AnyView(
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                        .frame(minWidth: 44, minHeight: 44)
                )
            @unknown default:
                view = AnyView(
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.gray)
                        .frame(minWidth: 44, minHeight: 44)
                )
            }

            return view
        }
    }
}
