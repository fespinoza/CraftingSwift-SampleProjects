import SwiftUI
import Models

struct PostList: View {
    @State var posts: [Post] = []

    var body: some View {
        List(posts) { post in
            PostRow(post: post)
        }
        .listStyle(.plain)
        .task { loadTestData() }
        .navigationTitle("Posts")
    }

    func loadTestData() {
        do {
            let testData = TestData()
            try testData.loadData()
            posts = Array(testData.posts.prefix(upTo: 10))
        } catch {
            dump(error)
        }
    }
}

struct PostRow: View {
    let post: Post

    var body: some View {
        VStack(spacing: 20) {
            VStack {
                AsyncImage(url: post.metadata.imageURL) { image in
                    image
                        .resizable()
                } placeholder: {
                    Color.gray.opacity(0.4)
                }
                .frame(height: 200)
                .overlay {
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .clear, location: 0.5),
                            .init(color: .black.opacity(0.8), location: 1),
                        ],
                        startPoint: .init(x: 0, y: 0),
                        endPoint: .init(x: 0, y: 1)
                    )
                }
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading) {
                        Text(post.metadata.publishedDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)

                        Text(post.metadata.title)
                            .bold()
                    }
                    .padding(8)
                    .foregroundStyle(Color.white)
                }
//                .overlay(alignment: .topTrailing) {
//                    Button("Like", systemImage: "hand.thumbsup", action: {})
//                        .labelStyle(.iconOnly)
//                        .font(.title2)
//                        .padding(8)
//                        .foregroundStyle(Color.white)
//                        .symbolVariant(post.socialInfo.isLiked ? .fill : .none)
//                }

                VStack(alignment: .leading) {
//                        Text(post.metadata.publishedDate.formatted(date: .abbreviated, time: .omitted))
//                            .font(.caption)
//
//                        Text(post.metadata.title)
//                            .bold()

                    Text(post.metadata.summary)
                        .foregroundStyle(.secondary)

                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(post.metadata.tags) { tag in
                                Text(tag.name)
                                    .foregroundStyle(Color.white)
                                    .font(.caption)
                                    .bold()
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundStyle(Color.indigo)
                                    )
                            }
                        }
                    }

                    HStack {
                        Text("\(post.socialInfo.likeCount) likes")
                        Text("\(post.socialInfo.commentCount) comments")
                    }
                    .font(.caption)
                }
            }

//                HStack {
//                    Button("Like", systemImage: "hand.thumbsup", action: {})
//                        .symbolVariant(post.socialInfo.isLiked ? .fill : .none)
//                        .frame(maxWidth: .infinity)
//
//                    Button("Comment", systemImage: "bubble.left.and.bubble.right", action: {})
//                        .frame(maxWidth: .infinity)
//                }
        }
    }
}

#Preview {
    NavigationStack {
        PostList()
    }
}
