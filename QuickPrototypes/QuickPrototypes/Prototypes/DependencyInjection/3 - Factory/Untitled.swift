import Foundation
import FactoryKit
import SwiftUI

private extension Container {
    var socialClient: Factory<PostSocialNetworkingClient> {
        self { .live() }
    }

    var showLikesCount: Factory<Bool> {
        self { true }
    }
}

enum DependencyInjection_Factory_Two {
    @Observable
    class PostStore {
        // the trick is that there is just 1 instance of a PostType with the given ID
        var store: [PostType.ID: PostType] = [:]
    }

    // This model is a mix with view model
    @Observable
    class PostType: Identifiable {
        let id: UUID
        var title: String
        var body: String
        var liked: Bool
        var likeCount: Int

        init(
            id: UUID,
            title: String,
            body: String,
            liked: Bool,
            likeCount: Int
        ) {
            self.id = id
            self.title = title
            self.body = body
            self.liked = liked
            self.likeCount = likeCount
        }

        init(post: Post) {
            self.id = post.id
            self.title = post.title
            self.body = post.body
            self.liked = post.liked
            self.likeCount = post.likeCount
        }

        @ObservationIgnored @Injected(\.socialClient) private var socialClient

        var likeCountDescription: String {
            "\(likeCount) likes"
        }

        func toggleLike() async {
            let value = liked
            likeCount += 1

            do {
                liked.toggle()
                if value {
                    try await socialClient.removeLike(id)
                } else {
                    try await socialClient.addLike(id)
                }
            } catch {
                liked = value
                likeCount -= 1
                print("request failed, reverting back to previous state")
            }
        }
    }

    struct LikeButton: View {
        let post: PostType
        @Injected(\.showLikesCount) private var showLikesCount

        var body: some View {
            HStack {
                Button(action: toggleLike) {
                    Text(post.liked ? "Liked" : "Like")
                }

                if showLikesCount {
                    Text(post.likeCountDescription)
                }
            }
        }

        func toggleLike() {
            Task { await post.toggleLike() }
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
