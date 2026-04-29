import SwiftUI
import Models

struct PostTagsGalleryScreen: View {
    @State private var listState: ListState = .idle
    @Environment(\.networkClient.fetchTagsWithCounts) var fetchTagsWithCounts
    @State private var tags: [Post.Tag] = []
    @State private var counts: [TagID: Int] = [:]

    var body: some View {
        Group {
            switch listState {
            case .idle:
                Color.clear
            case .loading:
                ProgressView()
            case .dataLoaded:
                PostTagsGalleryView(tags: tags, counts: counts)
            case .error(let error):
                Text(error.localizedDescription)
            }
        }
        .task { await initialLoad() }
        .navigationTitle("Tags")
    }

    func initialLoad() async {
        guard case .idle = listState else {
            return
        }
        listState = .loading

        do {
            let data = try await fetchTagsWithCounts()
            self.tags = data.tags
            self.counts = data.counts
            listState = .dataLoaded
        } catch {
            listState = .error(error)
        }
    }
}

struct PostSearchView: View {
    @State private var search: String = ""
    let data: TestData

    init() {
        self.data = TestData()
        try! data.loadData()
    }

    var body: some View {
        PostTagsGalleryView(tags: data.tags, counts: data.postByTagCount)
            .overlay {
                if search != "" {
                    SearchResultsView(for: search)
                }
            }
            .searchable(
                text: $search,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text("Search Post by Name, Content or Author")
            )
    }
}

struct SearchResultsView: View {
    let search: String

    init(for search: String) {
        self.search = search
    }

    var body: some View {
        PostListScreen(useCase: .search(search))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
    }
}

struct PostTagsGalleryView: View {
    let tags: [Post.Tag]
    let counts: [TagID: Int]

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    .init(.flexible(minimum: 20, maximum: 200)),
                    .init(.flexible(minimum: 20, maximum: 200)),
                ],
                alignment: .leading,
                spacing: 10
            ) {
                ForEach(tags, id: \.self) { tag in
                    NavigationLink(value: PostRoute.postsForTag(tag)) {
                        TagItemCountView(tag: tag, count: counts[tag.id, default: 0])
                    }
                }
            }
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview {
    NavigationStack {
        PostSearchView()
            .postDestinations()
    }
}

struct TagItemCountView: View {
    let tag: Post.Tag
    let count: Int

    var body: some View {
        HStack {
            Text(tag.name)
                .padding(.leading, 8)
                .padding(.vertical, 2)
            Text(count.formatted())
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.white.opacity(0.3))
        }
        .foregroundStyle(Color.white)
        .font(.caption)
        .bold()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.indigo)
        )
    }
}
