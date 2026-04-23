import Foundation
import Models

enum PostRoute: Hashable {
    case post(id: Post.ID)
    case allPosts
    case postsForTag(Post.Tag)
}
