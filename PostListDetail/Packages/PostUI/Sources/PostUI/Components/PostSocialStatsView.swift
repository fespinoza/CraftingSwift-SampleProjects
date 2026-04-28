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
