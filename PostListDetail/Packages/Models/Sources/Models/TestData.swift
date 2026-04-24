import Foundation

public class TestData {
    public var posts: [Post]
    public var tags: [Post.Tag]

    public init(posts: [Post] = [], tags: [Post.Tag] = []) {
        self.posts = posts
        self.tags = tags
    }

    public var post: Post {
        get throws {
            guard let first = posts.first else {
                throw TestDataError.unexpectedEmptyPostContent
            }
            return first
        }
    }

    public func loadData() throws {
        guard let url = Bundle.module.url(forResource: "posts", withExtension: "json") else {
            throw TestDataError.missingSourceFile
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        posts = try decoder.decode([Post].self, from: data)

        var uniqueTags: Set<Post.Tag> = []
        var uniqueTagNames: Set<String> = []

        posts.forEach {
            $0.metadata.tags.forEach { tag in
                if uniqueTagNames.contains(tag.name) {
                    return
                }

                uniqueTagNames.insert(tag.name)
                uniqueTags.insert(tag)
            }
        }

        tags = Array(uniqueTags).sorted { $0.name < $1.name }
    }
}

public enum TestDataError: Error, LocalizedError {
    case missingSourceFile
    case unexpectedEmptyPostContent

    public var errorDescription: String? {
        switch self {
        case .missingSourceFile:
            return "Missing source file"
        case .unexpectedEmptyPostContent:
            return "Unexpected empty post content"
        }
    }
}
