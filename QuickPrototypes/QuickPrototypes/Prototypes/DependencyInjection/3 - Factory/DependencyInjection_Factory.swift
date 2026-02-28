import Foundation
import FactoryKit
import SwiftUI

private nonisolated class AnalyticsProvider {
    init() {}

    static let shared: AnalyticsProvider = .init()

    func track(eventName: String) {
        print("perform tracking of event \(eventName)...")
    }
}

private extension Container {
    var socialClient: Factory<PostSocialNetworkingClient> {
        self { .live() }
    }

    var showLikesCount: Factory<Bool> {
        self { true }
    }

    var httpClient: Factory<HttpClient> {
        self { .live() }
    }

    var analyticsProvider: Factory<AnalyticsProvider> {
        self { .shared } // !!!
    }
}

enum DependencyInjection_Factory {


@MainActor
@Observable
class PostListViewModel {
    var posts: [Post] = []
    @ObservationIgnored @Injected(\.httpClient) private var httpClient
    @ObservationIgnored @Injected(\.analyticsProvider) private var analytics

    init() {}

    func loadData() async {
        do {
            posts = try await httpClient.fetchPosts()
            analytics.track(eventName: "Loaded Posts")
        } catch {
            analytics.track(eventName: "Failed to Load Posts")
            print(error.localizedDescription)
        }
    }
}


    struct LikeButton: View {
        @State var viewModel: LikeButtonViewModel
        @Injected(\.showLikesCount) private var showLikesCount

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
        }

        func toggleLike() {
            Task { await viewModel.toggleLike() }
        }
    }

    @Observable
    class LikeButtonViewModel {
        let postID: Post.ID
        var liked: Bool
        var likeCount: Int

        @ObservationIgnored @Injected(\.socialClient) private var socialClient

        var likeCountDescription: String {
            "\(likeCount) likes"
        }

        init(post: Post) {
            self.postID = post.id
            self.liked = post.liked
            self.likeCount = post.likeCount
        }

        func toggleLike() async {
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

//    @Suite
//    struct LikeButtonViewModelTests {
//        @Test
//        func `on a failed like request, the state should be reverted`() async throws {
//            Container.shared.socialClient.register {
//                PostSocialNetworkingClient.test(
//                    addLike: { _ in throw NSError(domain: "Something went wrong", code: 0) }
//                )
//            }
//
//            let viewModel = LikeButtonViewModel(post: .previewValue(liked: false, likeCount: 3))
//
//            await viewModel.toggleLike()
//
//            #expect(viewModel.likeCount == 3 && !viewModel.liked, "The state didn't change because the request failed")
//        }
//    }
}
