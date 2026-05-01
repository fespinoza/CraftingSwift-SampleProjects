import Foundation
import Tagged

public typealias PostID = Tagged<Post, UUID>
public typealias TagID = Tagged<Post.Tag, UUID>
public typealias CommentID = Tagged<Post.Comment, UUID>
public typealias AuthorID = Tagged<Post.Comment.Author, UUID>

public struct Post: Decodable, Identifiable, Equatable, Sendable {
    public let metadata: Metadata
    public var socialInfo: SocialInfo
    public let content: AttributedString

    public init(metadata: Metadata, socialInfo: SocialInfo, content: AttributedString) {
        self.metadata = metadata
        self.socialInfo = socialInfo
        self.content = content
    }

    public var id: PostID { metadata.id }
}

public struct PostItem: Decodable, Identifiable {
    public let metadata: Post.Metadata
    public let socialInfo: Post.SocialInfo

    public init(metadata: Post.Metadata, socialInfo: Post.SocialInfo) {
        self.metadata = metadata
        self.socialInfo = socialInfo
    }

    public var id: PostID { metadata.id }
}

public protocol PostInformation {
    var id: PostID { get }
    var title: String { get }
    var summary: String { get }
    var imageURL: URL { get }
    var publishedDate: Date { get }
    var tags: [Post.Tag] { get }
}

public protocol Likable {
    var likeCount: Int { get }
    var isLiked: Bool { get set }
}

extension Post {
    public struct Summary: Decodable, Equatable, Identifiable, Sendable, PostInformation, Likable {
        public let id: PostID
        public let title: String
        public let summary: String
        public let imageURL: URL
        public let publishedDate: Date
        public let tags: [Tag]
        public let likeCount: Int
        public var isLiked: Bool
        public let commentCount: Int

        public init(
            id: PostID,
            title: String,
            summary: String,
            imageURL: URL,
            publishedDate: Date,
            tags: [Tag],
            likeCount: Int,
            isLiked: Bool,
            commentCount: Int
        ) {
            self.id = id
            self.title = title
            self.summary = summary
            self.imageURL = imageURL
            self.publishedDate = publishedDate
            self.tags = tags
            self.likeCount = likeCount
            self.isLiked = isLiked
            self.commentCount = commentCount
        }

        public init(post: Post) {
            self.init(
                id: post.metadata.id,
                title: post.metadata.title,
                summary: post.metadata.summary,
                imageURL: post.metadata.imageURL,
                publishedDate: post.metadata.publishedDate,
                tags: post.metadata.tags,
                likeCount: post.socialInfo.likeCount,
                isLiked: post.socialInfo.isLiked,
                commentCount: post.socialInfo.commentCount
            )
        }
    }

    public struct Metadata: Decodable, Equatable, Identifiable, Sendable, PostInformation {
        public let id: PostID
        public let title: String
        public let summary: String
        public let imageURL: URL
        public let publishedDate: Date
        public let tags: [Tag]

        public init(id: PostID, title: String, summary: String, imageURL: URL, publishedDate: Date, tags: [Tag]) {
            self.id = id
            self.title = title
            self.summary = summary
            self.imageURL = imageURL
            self.publishedDate = publishedDate
            self.tags = tags
        }
    }

    public struct Tag: Decodable, Sendable, Identifiable, Equatable, Hashable {
        public let id: TagID
        public let name: String

        public init(id: TagID, name: String) {
            self.id = id
            self.name = name
        }
    }

    public struct SocialInfo: Decodable, Equatable, Sendable, Likable {
        public let likeCount: Int
        public var isLiked: Bool
        public let comments: [Comment]

        public var commentCount: Int { comments.count }

        public init(likeCount: Int, isLiked: Bool, comments: [Comment]) {
            self.likeCount = likeCount
            self.isLiked = isLiked
            self.comments = comments
        }
    }

    public struct Comment: Decodable, Sendable, Identifiable, Equatable {
        public let id: CommentID
        public let content: String
        public let author: Author
        public let socialInfo: SocialInfo

        public init(id: CommentID, content: String, author: Author, socialInfo: SocialInfo) {
            self.id = id
            self.content = content
            self.author = author
            self.socialInfo = socialInfo
        }
    }
}

extension Post.Comment {
    public struct Author: Decodable, Sendable, Identifiable, Equatable {
        public let id: AuthorID
        public let firstName: String
        public let lastName: String
        public let photoURL: URL

        public init(id: AuthorID, firstName: String, lastName: String, photoURL: URL) {
            self.id = id
            self.firstName = firstName
            self.lastName = lastName
            self.photoURL = photoURL
        }
    }

    public struct SocialInfo: Decodable, Sendable, Equatable, Likable {
        public let likeCount: Int
        public var isLiked: Bool

        public init(likeCount: Int, isLiked: Bool) {
            self.likeCount = likeCount
            self.isLiked = isLiked
        }
    }
}
