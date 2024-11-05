//
//  CachedAsyncImage.swift
//  Recipe App
//
//  Created by Sergio Rodriguez on 11/4/24.
//

import SwiftUI

struct CachedAsyncImage<Content: View>: View {
    let url: URL?
    let scale: CGFloat
    let content: (AsyncImagePhase) -> Content

    @State private var phase: AsyncImagePhase = .empty

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

// Convenience extension for simple usage
extension CachedAsyncImage where Content == AnyView {
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
