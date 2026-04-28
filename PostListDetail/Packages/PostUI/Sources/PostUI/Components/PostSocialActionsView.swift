import SwiftUI
import Models

struct PostSocialActionsView: View {
    @State var post: Likable
    let postId: PostID
    @Environment(\.networkClient) var networkClient

    init(post: Likable, postId: PostID) {
        self._post = .init(initialValue: post)
        self.postId = postId
    }

    var body: some View {
        HStack {
            Button("Like", systemImage: "hand.thumbsup", action: toggleLike)
                .symbolVariant(post.isLiked ? .fill : .none)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderless)

            Button("Comment", systemImage: "bubble.left.and.bubble.right", action: addComment)
                .frame(maxWidth: .infinity)
        }
    }

    // This state is not synced!

    func toggleLike() {
        let originalValue = post.isLiked

        post.isLiked.toggle()

        if originalValue {
            Task {
                do {
                    try await networkClient.unlikePost(postId)
                } catch {
                    post.isLiked = originalValue
                }
            }
        } else {
            Task {
                do {
                    try await networkClient.likePost(postId)
                } catch {
                    post.isLiked = originalValue
                }
            }
        }
    }

    func addComment() {

    }
}

@Observable
class PostSocialLocator {
    private var cache: [PostID: PostSocialState] = [:]

    func state(for postID: PostID) -> PostSocialState {
        if let state = cache[postID] {
            return state
        } else {
            let state = PostSocialState(postId: postID, isLiked: false, likeCount: 0)
            cache[postID] = state
            state.container = self
            return state
        }
    }

    func setValues(for post: Post.Summary) {
        let state = state(for: post.id)
        state.isLiked = post.isLiked
        state.likeCount = post.likeCount
    }
}

@Observable
class PostSocialState {
    let postId: PostID
    var isLiked: Bool
    var likeCount: Int
    weak var container: PostSocialLocator?

    init(postId: PostID, isLiked: Bool, likeCount: Int) {
        self.postId = postId
        self.isLiked = isLiked
        self.likeCount = likeCount
    }
}
