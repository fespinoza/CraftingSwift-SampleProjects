import Foundation
import Models

/*
 - Post.Metadata is "lightweight", unlike the full Post data
 */

struct TagsWithCounts: Decodable {
    let tags: [Post.Tag]
    let counts: [TagID: Int]
}

struct NetworkClient {
    let fetchPostSummaries: () async throws -> [Post.Summary] // Pagination
    let fetchPost: (PostID) async throws -> Post
    let fetchTagsWithCounts: () async throws -> TagsWithCounts
    let searchPosts: (String) async throws -> [Post.Summary] // Pagination

    let likePost: (PostID) async throws -> Void
    let unlikePost: (PostID) async throws -> Void

    let addComment: (PostID, String) async throws -> Void
    let removeComment: (CommentID) async throws -> Void

    private static func randomDelay() async throws {
        try await Task.sleep(for: .seconds(1))
//        try await Task.sleep(for: .seconds((1...4).randomElement() ?? 1))
    }

    static func debug() -> Self {
        let testData = TestData()
        try! testData.loadData()

        return .init(
            fetchPostSummaries: {
                try await randomDelay()
                let result = testData.posts.map { Post.Summary(post: $0) }

                Task { @MainActor [result] in
                    result.forEach { PostSocialLocator.shared.setValues(for: $0) }
                }

                return result
            },
            fetchPost: { postId in
                try await randomDelay()
                guard let post = testData.posts.first(where: { $0.id == postId }) else {
                    throw DebugNetworkError.postNotFound(postId)
                }

                Task { @MainActor [post] in
                    PostSocialLocator.shared.setValues(for: post)
                }

                return post
            },
            fetchTagsWithCounts: {
                try await randomDelay()
                return .init(
                    tags: testData.tags,
                    counts: testData.postByTagCount
                )
            },
            searchPosts: { query in
                try await randomDelay()
                return testData
                    .posts
                    .filter { $0.metadata.title.localizedCaseInsensitiveContains(query) }
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
        fetchTagsWithCounts: @escaping () async throws -> TagsWithCounts = { fatalError("❌ not implemented") },
        searchPosts: @escaping (String) async throws -> [Post.Summary] = { _ in fatalError("❌ not implemented") },
        likePost: @escaping (PostID) async throws -> Void = { _ in fatalError("❌ not implemented") },
        unlikePost: @escaping (PostID) async throws -> Void = { _ in fatalError("❌ not implemented") },
        addComment: @escaping (PostID, String) async throws -> Void = { _,_ in fatalError("❌ not implemented") },
        removeComment: @escaping (CommentID) async throws -> Void = { _ in fatalError("❌ not implemented") }
    ) -> Self {
        self.init(
            fetchPostSummaries: fetchPostSummaries,
            fetchPost: fetchPost,
            fetchTagsWithCounts: fetchTagsWithCounts,
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
