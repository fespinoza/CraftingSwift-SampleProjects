import Foundation
import SwiftUI

enum PostPalette {
    static let ink = Color(red: 0.12, green: 0.15, blue: 0.22)
    static let mutedInk = Color(red: 0.35, green: 0.39, blue: 0.47)
    static let cream = Color(red: 0.98, green: 0.95, blue: 0.90)
    static let mist = Color(red: 0.91, green: 0.95, blue: 0.99)
    static let accent = Color(red: 0.83, green: 0.38, blue: 0.25)
    static let accentSecondary = Color(red: 0.19, green: 0.48, blue: 0.56)
    static let accentSoft = Color(red: 0.95, green: 0.82, blue: 0.73)
}

struct PostSceneBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [PostPalette.cream, PostPalette.mist],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(
                    RadialGradient(
                        colors: [PostPalette.accentSoft.opacity(0.75), .clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 180
                    )
                )
                .frame(width: 320, height: 320)
                .offset(x: 145, y: -240)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [PostPalette.accentSecondary.opacity(0.18), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 220
                    )
                )
                .frame(width: 380, height: 380)
                .offset(x: -160, y: 320)

            Rectangle()
                .fill(.white.opacity(0.14))
                .blur(radius: 90)
                .rotationEffect(.degrees(-18))
                .offset(y: 160)
        }
        .ignoresSafeArea()
    }
}

private struct PostSurfaceModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(0.45), lineWidth: 1)
            }
            .shadow(color: PostPalette.ink.opacity(0.08), radius: 22, x: 0, y: 14)
    }
}

extension View {
    func postSurface(cornerRadius: CGFloat = 30) -> some View {
        modifier(PostSurfaceModifier(cornerRadius: cornerRadius))
    }
}

struct PostRemoteImage<Overlay: View>: View {
    let url: URL
    let height: CGFloat
    let cornerRadius: CGFloat
    @ViewBuilder let overlay: Overlay

    init(
        url: URL,
        height: CGFloat,
        cornerRadius: CGFloat = 30,
        @ViewBuilder overlay: () -> Overlay = { EmptyView() }
    ) {
        self.url = url
        self.height = height
        self.cornerRadius = cornerRadius
        self.overlay = overlay()
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: url, transaction: .init(animation: .easeInOut(duration: 0.25))) { phase in
                switch phase {
                case .empty:
                    placeholder

                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()

                case .failure:
                    failure

                @unknown default:
                    placeholder
                }
            }

            LinearGradient(
                colors: [.clear, PostPalette.ink.opacity(0.76)],
                startPoint: .center,
                endPoint: .bottom
            )

            overlay
                .padding(20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(.white.opacity(0.16), lineWidth: 1)
        }
    }

    private var placeholder: some View {
        ZStack {
            LinearGradient(
                colors: [PostPalette.accentSoft, PostPalette.mist],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: "photo.stack")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(PostPalette.accent.opacity(0.7))
        }
    }

    private var failure: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.91, green: 0.89, blue: 0.88), Color(red: 0.98, green: 0.95, blue: 0.92)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(PostPalette.accent)
        }
    }
}
