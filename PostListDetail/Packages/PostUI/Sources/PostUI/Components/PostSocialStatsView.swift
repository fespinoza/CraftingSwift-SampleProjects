import SwiftUI
import Models

struct PostSocialStatsView: View {
    let likeCount: Int
    let commentCount: Int

    var body: some View {
        HStack {
            Text("\(likeCount) likes")
            Text("\(commentCount) comments")
        }
        .font(.caption)
    }
}

struct NewPostSocialStatsView: View {
//    let likeCount: Int
//    let commentCount: Int

    let post: PostSocialState

    init(postID: PostID) {
        post = PostSocialLocator.shared.state(for: postID)
    }

    var body: some View {
        HStack {
            Text("\(post.likeCount) likes")
            Text("XXX comments")
        }
        .font(.caption)
    }
}
