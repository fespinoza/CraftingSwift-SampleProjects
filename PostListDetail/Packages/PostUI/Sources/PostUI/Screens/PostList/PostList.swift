import SwiftUI
import Models

struct PostList: View {
    let posts: [Post.Summary]
    let title: String
    let subtitle: String

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 22) {
                PostFeedHeader(
                    title: title,
                    subtitle: subtitle,
                    count: posts.count
                )

                ForEach(posts) { post in
                    NavigationLink(value: PostRoute.post(id: post.id)) {
                        PostRow(post: post)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 34)
        }
        .scrollIndicators(.hidden)
    }
}

struct PostRow: View {
    let post: Post.Summary

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            PostRemoteImage(url: post.imageURL, height: 220) {
                HStack(alignment: .bottom) {
                    Text(post.publishedDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(.footnote, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white.opacity(0.94))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.14), in: Capsule())

                    Spacer()

                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.95))
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text(post.title)
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(PostPalette.ink)
                    .multilineTextAlignment(.leading)

                Text(post.summary)
                    .font(.body)
                    .foregroundStyle(PostPalette.mutedInk)
                    .lineSpacing(4)
                    .multilineTextAlignment(.leading)

                PostTagList(tags: post.tags, isNavigationEnabled: false)

                HStack(alignment: .center, spacing: 12) {
                    PostSocialStatsView(
                        likeCount: post.likeCount,
                        commentCount: post.commentCount
                    )

                    Spacer()

                    Label("Read Story", systemImage: "arrow.right")
                        .font(.system(.footnote, design: .rounded).weight(.bold))
                        .foregroundStyle(PostPalette.accent)
                }
            }
        }
        .postSurface()
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens the post details")
    }
}

private struct PostFeedHeader: View {
    let title: String
    let subtitle: String
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Curated Feed")
                    .font(.system(.footnote, design: .rounded).weight(.semibold))
                    .foregroundStyle(PostPalette.accent)
                    .textCase(.uppercase)

                Spacer()

                Text("\(count) posts")
                    .font(.system(.footnote, design: .rounded).weight(.semibold))
                    .foregroundStyle(PostPalette.mutedInk)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.48), in: Capsule())
            }

            Text(title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(PostPalette.ink)

            Text(subtitle)
                .font(.body)
                .foregroundStyle(PostPalette.mutedInk)
                .lineSpacing(4)
        }
        .postSurface(cornerRadius: 34)
    }
}
