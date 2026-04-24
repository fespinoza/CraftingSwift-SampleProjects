import SwiftUI
import Models

struct PostDetailView: View {
    let post: Post

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                AsyncImage(
                    url: post.metadata.imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }

                VStack(alignment: .leading) {
                    Text(post.metadata.publishedDate.formatted(date: .abbreviated, time: .omitted))


                    Text(post.metadata.title)
                        .bold()
                        .font(.largeTitle)

                    Text(post.metadata.summary)

                    Text(post.content)

                    PostTagList(tags: post.metadata.tags)

                    Divider()

                    PostSocialStatsView(socialInfo: post.socialInfo)

                    PostSocialActionsView(post: post)

                    Divider()

                    LazyVStack(alignment: .leading) {
                        ForEach(post.socialInfo.comments) { comment in
                            HStack(alignment: .top) {
                                Circle()
                                    .frame(width: 40)

                                VStack(alignment: .leading) {
                                    Text(comment.author.firstName + " " + comment.author.lastName)
                                        .bold()

                                    Text(comment.content)

                                    HStack {
                                        Button("Like", systemImage: "hand.thumbsup", action: {})
                                            .symbolVariant(comment.socialInfo.isLiked ? .fill : .none)
                                        Spacer()
                                        Text("\(comment.socialInfo.likeCount) likes")
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .multilineTextAlignment(.leading)
        }
        .ignoresSafeArea(.container, edges: .top)
//        .navigationTitle(post.metadata.title)
    }
}

private struct Demo: View {
    @State var post: Post?

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
