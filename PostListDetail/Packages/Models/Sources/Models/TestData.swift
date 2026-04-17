import Foundation

public class TestData {
    public var posts: [Post]

    public init(posts: [Post] = []) {
        self.posts = posts
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
