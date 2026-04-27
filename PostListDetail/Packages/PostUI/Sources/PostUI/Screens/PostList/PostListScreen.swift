//
//  File.swift
//  PostUI
//
//  Created by Felipe Espinoza on 24/04/2026.
//

import SwiftUI
import Models

private enum ListState {
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
        ZStack {
            PostSceneBackground()

            switch listState {
            case .idle:
                Color.clear

            case .loading:
                ProgressView("Loading posts")
                    .tint(PostPalette.accent)
                    .postSurface()
                    .padding(.horizontal, 20)

            case .dataLoaded:
                PostList(
                    posts: list,
                    title: heroTitle,
                    subtitle: heroSubtitle
                )

            case let .error(error):
                ContentUnavailableView(
                    "Couldn't Load Posts",
                    systemImage: "exclamationmark.bubble.fill",
                    description: Text(error.localizedDescription)
                )
                .padding(.horizontal, 20)
                .postSurface()
                .padding(.horizontal, 20)
            }
        }
        .task { await initialLoad() }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func initialLoad() async {
        guard case .idle = listState else { return }

        listState = .loading

        do {
            let summaries = try await networkClient.fetchPostSummaries()
            self.list = filteredSummaries(from: summaries)
            listState = .dataLoaded
        } catch {
            listState = .error(error)
        }
    }

    private func filteredSummaries(from summaries: [Post.Summary]) -> [Post.Summary] {
        switch useCase {
        case .allPosts:
            summaries
        case let .postForTag(tag):
            summaries.filter { summary in
                summary.tags.contains(tag)
            }
        }
    }

    private var navigationTitle: String {
        switch useCase {
        case .allPosts:
            "Feed"
        case .postForTag(let tag):
            tag.name
        }
    }

    private var heroTitle: String {
        switch useCase {
        case .allPosts:
            "Today's Swift Notes"
        case let .postForTag(tag):
            "\(tag.name) Collection"
        }
    }

    private var heroSubtitle: String {
        switch useCase {
        case .allPosts:
            "Thoughtful write-ups, practical patterns, and small UI details worth stealing."
        case let .postForTag(tag):
            "Every story tagged with \(tag.name), gathered in one calmer place."
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
