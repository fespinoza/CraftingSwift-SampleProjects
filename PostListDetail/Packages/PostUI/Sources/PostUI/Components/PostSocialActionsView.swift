import SwiftUI
import Models

struct PostSocialActionsView: View {
    let post: Post

    var body: some View {
        HStack {
            Button("Like", systemImage: "hand.thumbsup", action: {})
                .symbolVariant(post.socialInfo.isLiked ? .fill : .none)
                .frame(maxWidth: .infinity)

            Button("Comment", systemImage: "bubble.left.and.bubble.right", action: {})
                .frame(maxWidth: .infinity)
        }
    }
}
