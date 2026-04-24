import Foundation
import Models

/*
 - Post.Metadata is "lightweight", unlike the full Post data
 */

struct NetworkClient {
    let fetchPostSummaries: () async throws -> [Post.Metadata] // Pagination
    let fetchPost: (PostID) async throws -> Post
    let fetchTags: () async throws -> [Post.Tag]
    let searchPosts: (String) async throws -> [Post.Metadata] // Pagination

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
                return testData.posts.map(\.metadata)
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
                return testData
                    .posts
                    .filter { $0.metadata.title.localizedCaseInsensitiveContains(query) }
                    .map(\.metadata)

            },
            likePost: { _ in },
            unlikePost: { _ in },
            addComment: { _, _ in },
            removeComment: { _ in }
        )
    }

    static func manualDebug(
        fetchPostSummaries: @escaping () async throws -> [Post.Metadata] = { fatalError("❌ not implemented") },
        fetchPost: @escaping (PostID) async throws -> Post = { _ in fatalError("❌ not implemented") },
        fetchTags: @escaping () async throws -> [Post.Tag] = { fatalError("❌ not implemented") },
        searchPosts: @escaping (String) async throws -> [Post.Metadata] = { _ in fatalError("❌ not implemented") },
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
