import SwiftUI
import Models

struct PostList: View {
    let title: String
    let tag: Post.Tag?
    @State var posts: [Post] = []

    init(title: String, posts: [Post] = []) {
        self.title = title
        self.posts = posts
        self.tag = nil
    }

    init(tag: Post.Tag, posts: [Post] = []) {
        self.tag = tag
        self.title = tag.name
        self.posts = posts
    }

    var body: some View {
        List(posts) { post in
            NavigationLink(value: PostRoute.post(id: post.id)) {
                PostRow(post: post)
            }
            .navigationLinkIndicatorVisibility(.hidden)
        }
        .listStyle(.plain)
        .task { loadTestData() }
        .navigationTitle(title)
    }

    func loadTestData() {
        do {
            let testData = TestData()
            try testData.loadData()

            if let tag {
                posts = Array(testData.posts.filter { $0.metadata.tags.contains(tag) })
            } else {
                posts = Array(testData.posts.prefix(upTo: 10))
            }
        } catch {
            dump(error)
        }
    }
}

struct PostRow: View {
    let post: Post

    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                AsyncImage(url: post.metadata.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.4)
                }
                .frame(width: 100, height: 100)
                .clipped()

                VStack(alignment: .leading) {
                    Text(post.metadata.publishedDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)

                    Text(post.metadata.title)
                        .bold()

                    Text(post.metadata.summary)
                        .foregroundStyle(.secondary)

                    PostTagList(tags: post.metadata.tags)

                    PostSocialStatsView(socialInfo: post.socialInfo)
                }
            }

            PostSocialActionsView(post: post)
        }
    }
}

#Preview {
    NavigationStack {
        PostList(title: "All Posts")
    }
}
