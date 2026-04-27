import SwiftUI
import Models

struct PostDetailView: View {
    let post: Post

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero

                VStack(alignment: .leading, spacing: 20) {
                    PostTagList(tags: post.metadata.tags)
                    articleSection
                    engagementSection
                    commentsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, -32)
                .padding(.bottom, 32)
            }
        }
        .scrollIndicators(.hidden)
        .background(PostSceneBackground())
        .ignoresSafeArea(.container, edges: .top)
        .navigationTitle(post.metadata.title)
    }

    private var hero: some View {
        PostRemoteImage(url: post.metadata.imageURL, height: 360, cornerRadius: 0) {
            VStack(alignment: .leading, spacing: 14) {
                Text(post.metadata.publishedDate.formatted(date: .complete, time: .omitted))
                    .font(.system(.footnote, design: .rounded).weight(.bold))
                    .foregroundStyle(.white.opacity(0.92))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.14), in: Capsule())

                Spacer(minLength: 0)

                Text(post.metadata.title)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)

                Text(post.metadata.summary)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.86))
                    .lineSpacing(4)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var articleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Article")
                .font(.system(.footnote, design: .rounded).weight(.bold))
                .foregroundStyle(PostPalette.accent)
                .textCase(.uppercase)

            Text(post.content)
                .font(.body)
                .foregroundStyle(PostPalette.ink)
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
        }
        .postSurface()
    }

    private var engagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Community Pulse")
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(PostPalette.ink)

            Text("See how readers are reacting before jumping into the conversation.")
                .font(.subheadline)
                .foregroundStyle(PostPalette.mutedInk)

            PostSocialStatsView(
                likeCount: post.socialInfo.likeCount,
                commentCount: post.socialInfo.commentCount
            )

            PostSocialActionsView(post: post.socialInfo)
        }
        .postSurface()
    }

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Reader Notes")
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(PostPalette.ink)

            ForEach(post.socialInfo.comments) { comment in
                CommentCard(comment: comment)
            }
        }
    }
}

private struct CommentCard: View {
    let comment: Post.Comment

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            AsyncImage(url: comment.author.photoURL) { phase in
                switch phase {
                case .empty:
                    avatarPlaceholder

                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()

                case .failure:
                    avatarPlaceholder

                @unknown default:
                    avatarPlaceholder
                }
            }
            .frame(width: 52, height: 52)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .strokeBorder(.white.opacity(0.7), lineWidth: 1)
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(comment.author.firstName + " " + comment.author.lastName)
                            .font(.headline)
                            .foregroundStyle(PostPalette.ink)

                        Text("\(comment.socialInfo.likeCount) likes")
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                            .foregroundStyle(PostPalette.mutedInk)
                    }

                    Spacer()

                    Image(systemName: comment.socialInfo.isLiked ? "heart.fill" : "heart")
                        .foregroundStyle(comment.socialInfo.isLiked ? PostPalette.accent : PostPalette.mutedInk)
                }

                Text(comment.content)
                    .font(.body)
                    .foregroundStyle(PostPalette.ink)
                    .lineSpacing(4)

                Button("Appreciate", systemImage: comment.socialInfo.isLiked ? "hand.thumbsup.fill" : "hand.thumbsup") {}
                    .buttonStyle(.plain)
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(PostPalette.accent)
            }
        }
        .postSurface(cornerRadius: 26)
    }

    private var avatarPlaceholder: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [PostPalette.accentSoft, .white],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(systemName: "person.fill")
                .foregroundStyle(PostPalette.accent.opacity(0.7))
        }
    }
}

private struct Demo: View {
    @State private var post: Post?

    var body: some View {
        Group {
            if let post {
                PostDetailView(post: post)
            } else {
                Text("Soon a post")
            }
        }
        .task {
            let data = TestData()
            try? data.loadData()
            post = try? data.post
        }
    }
}

#Preview {
    NavigationStack {
        Demo()
    }
}
