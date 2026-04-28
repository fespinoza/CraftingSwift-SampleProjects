import SwiftUI
import Models

struct PostList: View {
    let posts: [Post.Summary]

    var body: some View {
        List(posts) { post in
            NavigationLink(value: PostRoute.post(id: post.id)) {
                PostRow(post: post)
            }
            .navigationLinkIndicatorVisibility(.hidden)
        }
        .listStyle(.plain)
    }
}

struct PostRow: View {
    let post: Post.Summary

    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                AsyncImage(url: post.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.4)
                }
                .frame(width: 100, height: 100)
                .clipped()

                VStack(alignment: .leading) {
                    Text(post.publishedDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)

                    Text(post.title)
                        .bold()

                    Text(post.summary)
                        .foregroundStyle(.secondary)

                    PostTagList(tags: post.tags)

                    PostSocialStatsView(
                        likeCount: post.likeCount,
                        commentCount: post.commentCount
                    )
                }
            }

            PostSocialActionsView(post: post, postId: post.id)
        }
    }
}
