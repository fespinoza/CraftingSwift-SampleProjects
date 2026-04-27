import SwiftUI
import Models

struct PostSocialActionsView: View {
    let post: any Likable

    var body: some View {
        HStack(spacing: 12) {
            actionButton(
                title: post.isLiked ? "Liked" : "Like",
                systemImage: post.isLiked ? "hand.thumbsup.fill" : "hand.thumbsup",
                isProminent: post.isLiked
            )

            actionButton(
                title: "Comment",
                systemImage: "bubble.left.and.bubble.right",
                isProminent: false
            )
        }
    }

    private func actionButton(title: String, systemImage: String, isProminent: Bool) -> some View {
        Button(action: {}) {
            Label(title, systemImage: systemImage)
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(isProminent ? .white : PostPalette.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(isProminent ? PostPalette.accent : .white.opacity(0.5))
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(.white.opacity(isProminent ? 0 : 0.6), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}
