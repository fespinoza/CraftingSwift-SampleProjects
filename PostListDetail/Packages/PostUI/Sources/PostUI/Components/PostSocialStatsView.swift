import SwiftUI
import Models

struct PostSocialStatsView: View {
    let socialInfo: Post.SocialInfo

    var body: some View {
        HStack {
            Text("\(socialInfo.likeCount) likes")
            Text("\(socialInfo.commentCount) comments")
        }
        .font(.caption)

    }
}
