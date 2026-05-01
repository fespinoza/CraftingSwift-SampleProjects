import SwiftUI
import Models

typealias PostSocialActions = _InitialPostSocialActions

struct _AltInitialPostSocialActions: View {
    @Binding var post: Post
    @Environment(\.networkClient) var networkClient

    var body: some View {
        _BasePostSocialActionsView(
            likable: .init(
                get: { post.socialInfo },
                set: { newValue in
                    if let newSocialInfo = newValue as? Post.SocialInfo {
                        post.socialInfo = newSocialInfo
                    } else {
                        print("trying to set the wrong type of `Post.SocialInfo`")
                    }
                }
            ),
            postId: post.id
        )
    }
}

struct _InitialPostSocialActions: View {
    @Binding var postSummary: Post.Summary
    @Environment(\.networkClient) var networkClient

    var body: some View {
        _BasePostSocialActionsView(
            likable: .init(
                get: { postSummary },
                set: { newValue in
                    if let newPostSummary = newValue as? Post.Summary {
                        postSummary = newPostSummary
                    } else {
                        print("trying to set the wrong type of `Post.Summary`")
                    }
                }
            ),
            postId: postSummary.id
        )
    }

    var _body: some View {
        HStack {
            Button("Like", systemImage: "hand.thumbsup", action: toggleLike)
                .symbolVariant(postSummary.isLiked ? .fill : .none)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderless)

            Button("Comment", systemImage: "bubble.left.and.bubble.right", action: addComment)
                .frame(maxWidth: .infinity)
        }
    }

    // This state is not synced!

    func toggleLike() {
        let originalValue = postSummary.isLiked

        postSummary.isLiked.toggle()

        if originalValue {
            Task {
                do {
                    try await networkClient.unlikePost(postSummary.id)
                } catch {
                    postSummary.isLiked = originalValue
                }
            }
        } else {
            Task {
                do {
                    try await networkClient.likePost(postSummary.id)
                } catch {
                    postSummary.isLiked = originalValue
                }
            }
        }
    }

    func addComment() {

    }
}

struct _BasePostSocialActionsView: View {
    @Binding var likable: Likable
    let postId: PostID
    @Environment(\.networkClient) var networkClient

    var body: some View {
        HStack {
            Button("Like", systemImage: "hand.thumbsup", action: toggleLike)
                .symbolVariant(likable.isLiked ? .fill : .none)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderless)

            Button("Comment", systemImage: "bubble.left.and.bubble.right", action: addComment)
                .frame(maxWidth: .infinity)
        }
    }

    // This state is not synced!

    func toggleLike() {
        let originalValue = likable.isLiked

        likable.isLiked.toggle()

        if originalValue {
            Task {
                do {
                    try await networkClient.unlikePost(postId)
                } catch {
                    likable.isLiked = originalValue
                }
            }
        } else {
            Task {
                do {
                    try await networkClient.likePost(postId)
                } catch {
                    likable.isLiked = originalValue
                }
            }
        }
    }

    func addComment() {

    }
}

struct _PostSocialActionsView: View {
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
