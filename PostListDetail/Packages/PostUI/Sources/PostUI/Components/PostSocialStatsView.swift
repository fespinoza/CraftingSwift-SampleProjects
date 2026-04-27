import SwiftUI
import Models

struct PostSocialStatsView: View {
    let likeCount: Int
    let commentCount: Int

    var body: some View {
        HStack(spacing: 8) {
            StatPill(systemImage: "hand.thumbsup.fill", value: likeCount, label: "likes")
            StatPill(systemImage: "bubble.left.and.bubble.right.fill", value: commentCount, label: "comments")
        }
    }
}

private struct StatPill: View {
    let systemImage: String
    let value: Int
    let label: String

    var body: some View {
        Label {
            Text("\(value) \(label)")
        } icon: {
            Image(systemName: systemImage)
        }
        .font(.system(.caption, design: .rounded).weight(.semibold))
        .foregroundStyle(PostPalette.mutedInk)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.white.opacity(0.52), in: Capsule())
    }
}
