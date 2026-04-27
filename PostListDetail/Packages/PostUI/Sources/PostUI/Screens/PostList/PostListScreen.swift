//
//  File.swift
//  PostUI
//
//  Created by Felipe Espinoza on 24/04/2026.
//

import SwiftUI
import Models

enum ListState {
    case idle
    case loading
    case dataLoaded
    case error(Error)
}

struct PostListScreen: View {
    let useCase: UseCase
    @State private var listState: ListState = .idle
    @State private var list: [Post.Summary] = []
    @Environment(\.networkClient) private var networkClient

    var body: some View {
        Group {
            switch listState {
            case .idle:
                Color.clear

            case .loading:
                ProgressView()

            case .dataLoaded:
                PostList(posts: list)

            case let .error(error):
                Text(error.localizedDescription)
            }
        }
        .task { await initialLoad() }
        .navigationTitle(listTitle)
    }

    func initialLoad() async {
        guard case .idle = listState else { return }

        listState = .loading

        do {
            let summaries = try await networkClient.fetchPostSummaries()
            self.list = summaries
            listState = .dataLoaded
        } catch {
            listState = .error(error)
        }
    }

    var listTitle: String {
        switch useCase {
        case .allPosts:
            "All Posts"
        case .postForTag(let tag):
            "#\(tag.name)'s Posts"
        }
    }

    enum UseCase {
        case allPosts
        case postForTag(Post.Tag)
    }
}

#Preview {
    NavigationStack {
        PostListScreen(useCase: .allPosts)
            .postDestinations()
    }
}
