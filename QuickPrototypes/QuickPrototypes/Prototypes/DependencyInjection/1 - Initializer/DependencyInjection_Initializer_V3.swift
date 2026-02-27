import Foundation
import SwiftUI
//import Testing

enum DependencyInjection_Initializer_V3 {
    struct HttpClient {
        static func fetchPosts() async throws -> [Post] {
            fatalError("❌ not implemented... this talks to a backend API")
        }
    }

    nonisolated class AnalyticsProvider {
        init() {}

        static let shared: AnalyticsProvider = .init()

        func track(eventName: String) {
            print("perform tracking of event \(eventName)...")
        }
    }

    struct PostListScreen: View {
        let showLikesCount: Bool

        var body: some View {
            NavigationStack {
                PostListView(showLikesCount: showLikesCount)
                    .navigationTitle("Posts")
            }
        }
    }

struct PostListView: View {
    @State var viewModel: PostListViewModel = .init()
    let showLikesCount: Bool

    var body: some View {
        List(viewModel.posts) { post in
            PostItemView(post: post, showLikesCount: showLikesCount)
        }
        .task { await viewModel.loadData() }
    }
}

struct PostItemView: View {
    let post: Post
    let showLikesCount: Bool

    var body: some View {
        Text(post.title)

        if showLikesCount {
            Text("\(post.likeCount) likes")
        }
    }
}

@MainActor
@Observable
class PostListViewModel {
    var posts: [Post]
    private let fetchPosts: () async throws -> [Post]
    private let analytics: AnalyticsProvider

    init(
        fetchPosts: @escaping () async throws -> [Post] = HttpClient.fetchPosts,
        analytics: AnalyticsProvider = .shared
    ) {
        self.posts = []
        self.fetchPosts = fetchPosts
        self.analytics = analytics
    }

    func loadData() async {
        do {
            posts = try await fetchPosts()
            analytics.track(eventName: "Loaded Posts")
        } catch {
            analytics.track(eventName: "Failed to Load Posts")
            print(error.localizedDescription)
        }
    }
}




//@MainActor
//@Suite
//struct PostListViewModelTests {
//    @Test
//    func `the view model populates post from a network request to our backend`() async {
//        let viewModel = PostListViewModel(
//            fetchPosts: {
//                [
//                    Post(title: "Hello World!", body: "..."),
//                    Post(title: "Second Post", body: "..."),
//                    Post(title: "Third Post", body: "..."),
//                ]
//            })
//
//        await viewModel.loadData()
//
//        #expect(viewModel.posts.count == 3, "We should have gotten posts")
//    }
//}
}
