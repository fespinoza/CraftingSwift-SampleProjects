//
//  SharedCode.swift
//  QuickPrototypes
//
//  Created by Felipe Espinoza on 24/02/2026.
//

import Foundation

struct Post: Decodable, Identifiable {
    let id: UUID
    let title: String
    let body: String
    let liked: Bool
    let likeCount: Int

    static func previewValue(
        id: UUID = .init(),
        title: String = "Hello World",
        body: String = "A sample post",
        liked: Bool = false,
        likeCount: Int = 5
    ) -> Self {
        .init(
            id: id,
            title: title,
            body: body,
            liked: liked,
            likeCount: likeCount
        )
    }
}

nonisolated struct NetworkUtilities {
    static func makeRequest(method: String, to path: String) throws -> URLRequest {
        guard let url = URL(string: "https://mybackend.com/\(path)") else { throw NetworkingError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return request
    }

    static func check(response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw NetworkingError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkingError.badStatus(code: http.statusCode)
        }
    }
}

enum NetworkingError: Error {
    case invalidURL
    case invalidResponse
    case badStatus(code: Int)
}

nonisolated struct PostSocialNetworkingClient {

    let addLike: (Post.ID) async throws -> Void
    let removeLike: (Post.ID) async throws -> Void

    static func live() -> Self {
        .init(
            addLike: { id in
                let request = try NetworkUtilities.makeRequest(method: "POST", to: "posts/\(id.uuidString)/likes")
                let (_, response) = try await URLSession.shared.data(for: request)
                try NetworkUtilities.check(response: response)
            },
            removeLike: { id in
                let request = try NetworkUtilities.makeRequest(method: "DELETE", to: "posts/\(id.uuidString)/likes")
                let (_, response) = try await URLSession.shared.data(for: request)
                try NetworkUtilities.check(response: response)
            }
        )
    }

    static func test(
        addLike: @escaping (Post.ID) async throws -> Void = { _ in },
        removeLike: @escaping (Post.ID) async throws -> Void = { _ in }
    ) -> Self {
        .init(
            addLike: addLike,
            removeLike: removeLike
        )
    }
}
