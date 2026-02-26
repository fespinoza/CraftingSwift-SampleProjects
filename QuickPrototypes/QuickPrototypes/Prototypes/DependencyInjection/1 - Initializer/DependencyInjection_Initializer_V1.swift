import Foundation
import SwiftUI
//import Testing

enum DependencyInjection_Initializer_V1 {
    struct Post: Decodable {
        let title: String
        let body: String
    }

    struct HttpClient {
        static func fetchPosts() async throws -> [Post] {
            fatalError("❌ not implemented... this talks to a backend API")
        }
    }

@MainActor
@Observable
class PostListViewModel {
    var posts: [Post]

    init() {
        self.posts = []
    }

    func loadData() async {
        do {
            posts = try await HttpClient.fetchPosts()
        } catch {
            print(error.localizedDescription)
        }
    }
}

//@MainActor
//@Suite
//struct PostListViewModelTests {
//    @Test
//    func `the view model populates post from a network request to our backend`() async {
//        let viewModel = PostListViewModel()
//
//        await viewModel.loadData()
//
//        #expect(viewModel.posts.count != 0, "We should have gotten posts")
//    }
//}
}
