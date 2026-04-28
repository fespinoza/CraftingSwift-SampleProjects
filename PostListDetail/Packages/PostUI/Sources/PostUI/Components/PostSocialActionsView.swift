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

