import Foundation
import SwiftUI
//import Testing

nonisolated struct HttpClient {
    let fetchPosts: () async throws -> [Post]

    init(
        fetchPosts: @escaping () async throws -> [Post]
    ) {
        self.fetchPosts = fetchPosts
    }

    static func live() -> HttpClient {
        .init(
            fetchPosts: {
                let request = try NetworkUtilities.makeRequest(method: "GET", to: "/posts")
                let (data, _) = try await URLSession.shared.data(for: request)
                // assuming the request had a 200 status code
                return try JSONDecoder().decode([Post].self, from: data)
            }
        )
    }

    static func test(
        fetchPosts: @escaping () async throws -> [Post] = { [] }
    ) -> HttpClient {
        .init(fetchPosts: fetchPosts)
    }
}

private extension EnvironmentValues {
    @Entry var socialClient: DependencyInjection_Environment.PostSocialNetworkingClient = .live
    @Entry var httpClient: HttpClient = .live()
    @Entry var showLikesCount: Bool = true
}

enum DependencyInjection_Environment {
    struct HttpClient {
        static func fetchPosts() async throws -> [Post] {
            fatalError("❌ not implemented... this talks to a backend API")
        }
    }

    // NEXT: PostListScreen
    // shows the advantage of this approach
struct PostListScreen: View {
    var body: some View {
        NavigationStack {
            PostListView()
                .navigationTitle("Posts")
        }
    }
}

struct PostListView: View {
    @State var posts: [Post] = []
    @State var isLoading: Bool = false
    @Environment(\.httpClient) private var httpClient

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else {
                List(posts) { post in
                    PostItemView(post: post)
                }
            }
        }
        .task {
            defer { isLoading = false }
            do {
                isLoading = true
                posts = try await httpClient.fetchPosts()
            } catch {
                print("error loading posts")
            }
        }
    }
}

    struct PostItemView: View {
        let post: Post

        var body: some View {
            VStack {
                Text(post.title)
                    .frame(maxWidth: .infinity, alignment: .leading)

                LikeButton(post: post)
                    .monospacedDigit()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .environment(\.showLikesCount, false)
        }
    }

    struct PostSocialNetworkingClient {
        let addLike: (Post.ID) async throws -> Void
        let removeLike: (Post.ID) async throws -> Void

        static let live: Self = .init(
            addLike: { _ in fatalError("❌ POST /posts/:id/likes") },
            removeLike: { _ in fatalError("❌ DELETE /posts/:id/likes") }
        )

        static func test(
            addLike: @escaping (Post.ID) async -> Void = { _ in },
            removeLike: @escaping (Post.ID) async -> Void = { _ in }
        ) -> Self {
            .init(
                addLike: addLike,
                removeLike: removeLike
            )
        }
    }

    /*
     How to make a service that controls the state of likes of a post
     if the post likes number changes somewhere else, this view should update
     if the server pushes new data, the UI knows it needs to update
     in this case, we need an optimistic approach to the like
     */
    struct LikeButton: View { // this can be a good example for the view model service!
        let post: Post
        @State var liked: Bool
        @State var likeCount: Int
        @Environment(\.socialClient) var socialClient
        @Environment(\.showLikesCount) var showLikesCount

        // toggle showing like count

        init(post: Post) {
            self.post = post
            self._liked = .init(initialValue: post.liked)
            self._likeCount = .init(initialValue: post.likeCount)
        }

        var body: some View {
            HStack {
                Button(action: toggleLike) {
                    Text(liked ? "Liked" : "Like")
                }

                if showLikesCount {
                    Text("\(likeCount) likes")
                }
            }
        }
        
        func toggleLike() {
            Task {
                let value = liked

                do {
                    liked.toggle()
                    likeCount += value ? -1 : 1
                    if value {
                        try await socialClient.removeLike(post.id)
                    } else {
                        try await socialClient.addLike(post.id)
                    }
                } catch {
                    liked = value
                    likeCount += value ? 1 : -1
                    print("request failed, reverting back to previous state")
                }
            }
        }
    }

    #Preview {
        VStack {
            LikeButton(post: .previewValue(liked: true))

            LikeButton(post: .previewValue(liked: false, likeCount: 0))
        }
        .environment(
            \.socialClient,
             .test(
                addLike: { _ in try? await Task.sleep(for: .seconds(2)) },
                removeLike: { _ in try? await Task.sleep(for: .seconds(2)) }
             )
        )
    }

//    @MainActor
//    @Suite
//    struct PostListViewModelTests {
//        @Test
//        func `the view model populates post from a network request to our backend`() async {
//            let viewModel = PostListViewModel()
//
//            await viewModel.loadData()
//
//            #expect(viewModel.posts.count != 0, "We should have gotten posts")
//        }
//    }
}

/*

 // sample view hierarchy

 tab: home
    - PostSummaryView (#3)
        - LikeButton
 tab: blog
    PostListView
        - PostSummaryView (#1)
            - LikeButton
        - PostSummaryView (#2)
            - LikeButton
        - PostSummaryView (#3)
            - LikeButton
        - PostSummaryView (#4)
            - LikeButton

 environment will help you modify the dependency to a subtree

 */

private typealias PostListScreen = DependencyInjection_Environment.PostListScreen

#Preview {
//        PostListView()
    PostListScreen()
        .environment(\.httpClient, .test(fetchPosts: {
            try await Task.sleep(for: .seconds(2))
            return [.previewValue(), .previewValue()]
        }))
        .environment(
            \.socialClient,
             .test(
                addLike: { _ in try? await Task.sleep(for: .seconds(2)) },
                removeLike: { _ in try? await Task.sleep(for: .seconds(2)) }
             )
        )
}
