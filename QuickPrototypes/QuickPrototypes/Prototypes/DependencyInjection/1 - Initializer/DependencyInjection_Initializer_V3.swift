import Foundation
import SwiftUI
//import Testing

enum DependencyInjection_Initializer_V3 {
    struct Post: Decodable {
        let title: String
        let body: String
    }

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

@MainActor
@Observable
class PostListViewModel {
    var posts: [Post]
    let fetchPosts: () async throws -> [Post]
    let analytics: AnalyticsProvider

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
