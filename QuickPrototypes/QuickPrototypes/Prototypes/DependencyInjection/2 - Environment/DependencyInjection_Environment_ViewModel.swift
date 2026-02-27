import Foundation
import SwiftUI
//import Testing

private extension EnvironmentValues {
    @Entry var socialClient: PostSocialNetworkingClient = .live()
    @Entry var showLikesCount: Bool = true
    @Entry var httpClient: HttpClient = .live()
}

enum DependencyInjection_Environment_ViewModel {
    struct HttpClient {
        static func fetchPosts() async throws -> [Post] {
            fatalError("❌ not implemented... this talks to a backend API")
        }
    }

    struct PostItemView: View {
        let post: Post

        var body: some View {
            VStack {
                Text(post.title)
                LikeButton(post: post)
            }
        }
    }

    struct PostListView: View {
        @State var viewModel: PostListViewModel = .init()
        @Environment(\.httpClient) var httpClient

        var body: some View {
            List(viewModel.posts) { post in
                PostItemView(post: post)
            }
            .task {
                // awkward
                viewModel.fetchPosts = httpClient.fetchPosts
                await viewModel.loadData()
            }
        }
    }

    struct AltPostListView: View {
        @State var viewModel: PostListViewModel = .init()

        var body: some View {
            List(viewModel.posts) { post in
                PostItemView(post: post)
            }
            .task {
                await viewModel.loadData()
            }
        }
    }

    struct HttpClientReader: View {
        @Environment(\.httpClient) var httpClient

        var body: some View {
            AltPostListView(viewModel: .init(fetchPosts: httpClient.fetchPosts))
        }
    }

@MainActor
@Observable
class PostListViewModel {
    var posts: [Post]
    var fetchPosts: (() async throws -> [Post])?

    init(
        fetchPosts: (() async throws -> [Post])? = nil
    ) {
        self.posts = []
        self.fetchPosts = fetchPosts
    }

    func loadData() async {
        guard let fetchPosts else { return }
        do {
            posts = try await fetchPosts()
        } catch {
            print(error.localizedDescription)
        }
    }
}

    @Observable
    class LikeButtonViewModel {
        let postID: Post.ID
        var liked: Bool
        var likeCount: Int
        var socialClient: PostSocialNetworkingClient?

        var likeCountDescription: String {
            "\(likeCount) likes"
        }

        init(post: Post) {
            self.postID = post.id
            self.liked = post.liked
            self.likeCount = post.likeCount
        }

        func toggleLike() async {
            guard let socialClient else { return }
            let value = liked
            likeCount += 1

            do {
                liked.toggle()
                if value {
                    try await socialClient.removeLike(postID)
                } else {
                    try await socialClient.addLike(postID)
                }
            } catch {
                liked = value
                likeCount -= 1
                print("request failed, reverting back to previous state")
            }
        }
    }

    struct LikeButton: View {
        @State var viewModel: LikeButtonViewModel
        @Environment(\.socialClient) private var socialClient
        @Environment(\.showLikesCount) private var showLikesCount

        init(post: Post) {
            self._viewModel = .init(initialValue: .init(post: post))
        }

        var body: some View {
            HStack {
                Button(action: toggleLike) {
                    Text(viewModel.liked ? "Liked" : "Like")
                }

                if showLikesCount {
                    Text(viewModel.likeCountDescription)
                }
            }
            .onAppear {
                viewModel.socialClient = socialClient
            }
        }

        func toggleLike() {
            Task { await viewModel.toggleLike() }
        }
    }
}
