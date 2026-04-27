import SwiftUI
import Models

private enum DiscoveryState {
    case idle
    case loading
    case ready
    case error(String)
}

private enum SearchState {
    case idle
    case loading
    case ready
    case error(String)
}

struct PostSearchView: View {
    @State private var search = ""
    @State private var discoveryState: DiscoveryState = .idle
    @State private var searchState: SearchState = .idle
    @State private var tags: [Post.Tag] = []
    @State private var counts: [TagID: Int] = [:]
    @State private var results: [Post.Summary] = []

    @Environment(\.networkClient) private var networkClient

    var body: some View {
        ZStack {
            PostSceneBackground()

            Group {
                if trimmedSearch.isEmpty {
                    browseBody
                } else {
                    SearchResultsView(
                        search: trimmedSearch,
                        results: results,
                        state: searchState
                    )
                }
            }
        }
        .navigationTitle("Discover")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $search,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Search posts, topics, or ideas")
        )
        .task { await loadDiscoveryData() }
        .task(id: trimmedSearch) { await performSearch(for: trimmedSearch) }
    }

    private var trimmedSearch: String {
        search.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    @ViewBuilder
    private var browseBody: some View {
        switch discoveryState {
        case .idle, .loading:
            ProgressView("Loading topics")
                .tint(PostPalette.accent)
                .postSurface()
                .padding(.horizontal, 20)

        case .ready:
            PostTagsGalleryView(tags: tags, counts: counts)

        case let .error(message):
            ContentUnavailableView(
                "Couldn't Load Topics",
                systemImage: "square.grid.2x2.fill",
                description: Text(message)
            )
            .postSurface()
            .padding(.horizontal, 20)
        }
    }

    private func loadDiscoveryData() async {
        guard case .idle = discoveryState else { return }

        discoveryState = .loading

        do {
            let tags = try await networkClient.fetchTags()
            let summaries = try await networkClient.fetchPostSummaries()

            self.tags = tags
            self.counts = summaries.reduce(into: [:]) { partialResult, summary in
                for tag in summary.tags {
                    partialResult[tag.id, default: 0] += 1
                }
            }
            discoveryState = .ready
        } catch {
            discoveryState = .error(error.localizedDescription)
        }
    }

    private func performSearch(for query: String) async {
        guard query.isEmpty == false else {
            results = []
            searchState = .idle
            return
        }

        searchState = .loading

        do {
            try await Task.sleep(for: .milliseconds(250))
            results = try await networkClient.searchPosts(query)
            searchState = .ready
        } catch is CancellationError {
            return
        } catch {
            searchState = .error(error.localizedDescription)
        }
    }
}

private struct SearchResultsView: View {
    let search: String
    let results: [Post.Summary]
    let state: SearchState

    var body: some View {
        switch state {
        case .idle, .loading:
            ProgressView("Searching")
                .tint(PostPalette.accent)
                .postSurface()
                .padding(.horizontal, 20)

        case .ready where results.isEmpty:
            ContentUnavailableView.search(text: search)
                .postSurface()
                .padding(.horizontal, 20)

        case .ready:
            PostList(
                posts: results,
                title: "Search Results",
                subtitle: "Matches for \"\(search)\""
            )

        case let .error(message):
            ContentUnavailableView(
                "Search Failed",
                systemImage: "magnifyingglass.circle.fill",
                description: Text(message)
            )
            .postSurface()
            .padding(.horizontal, 20)
        }
    }
}

struct PostTagsGalleryView: View {
    let tags: [Post.Tag]
    let counts: [TagID: Int]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 22) {
                DiscoverHeader(tagCount: tags.count)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 14),
                        GridItem(.flexible(), spacing: 14),
                    ],
                    spacing: 14
                ) {
                    ForEach(tags, id: \.self) { tag in
                        NavigationLink(value: PostRoute.postsForTag(tag)) {
                            TagItemCountView(tag: tag, count: counts[tag.id, default: 0])
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
    }
}

private struct DiscoverHeader: View {
    let tagCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Topic Library")
                .font(.system(.footnote, design: .rounded).weight(.semibold))
                .foregroundStyle(PostPalette.accent)
                .textCase(.uppercase)

            Text("Browse by theme, then drop into the stories that match your mood.")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(PostPalette.ink)

            Text("Explore \(tagCount) tags spanning navigation, architecture, accessibility, and the little SwiftUI tricks that save time later.")
                .font(.body)
                .foregroundStyle(PostPalette.mutedInk)
                .lineSpacing(4)
        }
        .postSurface(cornerRadius: 34)
    }
}

struct TagItemCountView: View {
    let tag: Post.Tag
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text(countLabel)
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(.white.opacity(0.92))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(.white.opacity(0.14), in: Capsule())

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white.opacity(0.88))
            }

            Spacer(minLength: 12)

            VStack(alignment: .leading, spacing: 8) {
                Text(tag.name)
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)

                Text(detailText)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.84))
                    .lineSpacing(3)
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 170, alignment: .topLeading)
        .padding(18)
        .background(
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(.white.opacity(0.18), lineWidth: 1)
        }
        .shadow(color: PostPalette.ink.opacity(0.09), radius: 20, x: 0, y: 10)
    }

    private var countLabel: String {
        count == 1 ? "1 article" : "\(count) articles"
    }

    private var detailText: String {
        count == 0
            ? "Fresh territory for your next post."
            : "Open a focused stream of posts about \(tag.name.lowercased())."
    }

    private var gradientColors: [Color] {
        let palettes: [[Color]] = [
            [PostPalette.accent, Color(red: 0.56, green: 0.23, blue: 0.20)],
            [PostPalette.accentSecondary, Color(red: 0.13, green: 0.26, blue: 0.39)],
            [Color(red: 0.49, green: 0.43, blue: 0.21), Color(red: 0.73, green: 0.55, blue: 0.24)]
        ]

        let seed = tag.name.unicodeScalars.reduce(0) { partialResult, scalar in
            partialResult + Int(scalar.value)
        }

        return palettes[seed % palettes.count]
    }
}

#Preview {
    NavigationStack {
        PostSearchView()
            .postDestinations()
    }
}
