import Foundation

struct GitHubFileFetcher {
    func fetchEventsContent(branch: String) async throws -> Data {
        guard let token = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] else {
            throw FetchError.tokenNotSet
        }

        let rawUrl = "GITHUB_REPO_FOR_EVENT_DEFINITIONS/events.yaml?ref=\(branch)"

        guard let url = URL(string: rawUrl) else { throw FetchError.invalidUrl(rawUrl: rawUrl) }

        return try await fetchFile(from: url, with: token)
    }

    /// Fetches the raw contents of a file from a private GitHub repository
    private func fetchFile(from url: URL, with token: String) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("token \(token)", forHTTPHeaderField: "Authorization")
        // to return the raw file content
        request.addValue("application/vnd.github.v3.raw", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw FetchError.fetchError(statusCode: httpResponse.statusCode, message: message)
        }

        return data
    }

    enum FetchError: LocalizedError {
        case tokenNotSet
        case invalidUrl(rawUrl: String)
        case fetchError(statusCode: Int, message: String)

        var errorDescription: String? {
            switch self {
            case .tokenNotSet: "You need to configure your environment variable 'GITHUB_TOKEN'"
            case let .invalidUrl(rawUrl): "Invalid URL for file '\(rawUrl)'"
            case let .fetchError(statusCode, message): "Failed to fetch file \(statusCode) - \(message)"
            }
        }
    }
}
