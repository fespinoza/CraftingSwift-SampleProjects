import SwiftUI
import Models

struct TagItemView: View {
    let tag: Post.Tag

    var body: some View {
        Text(tag.name)
            .font(.system(.caption, design: .rounded).weight(.bold))
            .foregroundStyle(PostPalette.ink)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(.white.opacity(0.62))
            )
            .overlay {
                Capsule(style: .continuous)
                    .strokeBorder(PostPalette.accent.opacity(0.18), lineWidth: 1)
            }
    }
}

struct PostTagList: View {
    let tags: [Post.Tag]
    var isNavigationEnabled = true

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(tags) { tag in
                    if isNavigationEnabled {
                        NavigationLink(value: PostRoute.postsForTag(tag)) {
                            TagItemView(tag: tag)
                        }
                        .buttonStyle(.plain)
                    } else {
                        TagItemView(tag: tag)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    NavigationStack {
        PostTagList(tags: [.init(id: .init(), name: "foo"), .init(id: .init(), name: "bar")])
    }
    .padding()
}
