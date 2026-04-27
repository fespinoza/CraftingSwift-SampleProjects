import Foundation
import Models

/*
 - Post.Metadata is "lightweight", unlike the full Post data
 */

struct NetworkClient {
    let fetchPostSummaries: () async throws -> [Post.Summary] // Pagination
    let fetchPost: (PostID) async throws -> Post
    let fetchTags: () async throws -> [Post.Tag]
    let searchPosts: (String) async throws -> [Post.Summary] // Pagination

    let likePost: (PostID) async throws -> Void
    let unlikePost: (PostID) async throws -> Void

    let addComment: (PostID, String) async throws -> Void
    let removeComment: (CommentID) async throws -> Void

    private static func randomDelay() async throws {
        try await Task.sleep(for: .seconds((1...4).randomElement() ?? 1))
    }

    static func debug() -> Self {
        let testData = TestData()
        try! testData.loadData()

        return .init(
            fetchPostSummaries: {
                try await randomDelay()
                return testData.posts.map { Post.Summary(post: $0) }
            },
            fetchPost: { postId in
                try await randomDelay()
                guard let post = testData.posts.first(where: { $0.id == postId }) else {
                    throw DebugNetworkError.postNotFound(postId)
                }
                return post
            },
            fetchTags: {
                try await randomDelay()
                return testData.tags
            },
            searchPosts: { query in
                try await randomDelay()
                let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

                return testData
                    .posts
                    .filter { post in
                        guard normalizedQuery.isEmpty == false else { return true }

                        let authorNames = post.socialInfo.comments.map {
                            $0.author.firstName + " " + $0.author.lastName
                        }

                        return post.metadata.title.localizedCaseInsensitiveContains(normalizedQuery)
                            || post.metadata.summary.localizedCaseInsensitiveContains(normalizedQuery)
                            || post.content.description.localizedCaseInsensitiveContains(normalizedQuery)
                            || post.metadata.tags.contains(where: { $0.name.localizedCaseInsensitiveContains(normalizedQuery) })
                            || authorNames.contains(where: { $0.localizedCaseInsensitiveContains(normalizedQuery) })
                    }
                    .map { Post.Summary(post: $0) }

            },
            likePost: { _ in },
            unlikePost: { _ in },
            addComment: { _, _ in },
            removeComment: { _ in }
        )
    }

    static func manualDebug(
        fetchPostSummaries: @escaping () async throws -> [Post.Summary] = { fatalError("❌ not implemented") },
        fetchPost: @escaping (PostID) async throws -> Post = { _ in fatalError("❌ not implemented") },
        fetchTags: @escaping () async throws -> [Post.Tag] = { fatalError("❌ not implemented") },
        searchPosts: @escaping (String) async throws -> [Post.Summary] = { _ in fatalError("❌ not implemented") },
        likePost: @escaping (PostID) async throws -> Void = { _ in fatalError("❌ not implemented") },
        unlikePost: @escaping (PostID) async throws -> Void = { _ in fatalError("❌ not implemented") },
        addComment: @escaping (PostID, String) async throws -> Void = { _,_ in fatalError("❌ not implemented") },
        removeComment: @escaping (CommentID) async throws -> Void = { _ in fatalError("❌ not implemented") }
    ) -> Self {
        self.init(
            fetchPostSummaries: fetchPostSummaries,
            fetchPost: fetchPost,
            fetchTags: fetchTags,
            searchPosts: searchPosts,
            likePost: likePost,
            unlikePost: unlikePost,
            addComment: addComment,
            removeComment: removeComment
        )
    }
}

import SwiftUI

extension EnvironmentValues {
    @Entry var networkClient: NetworkClient = .debug()
}

enum DebugNetworkError: Error {
    case postNotFound(PostID)
}
