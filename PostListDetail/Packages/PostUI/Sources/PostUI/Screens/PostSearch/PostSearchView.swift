import SwiftUI
import Models

struct PostSearchView: View {
    @State private var search: String = ""

    var body: some View {
        PostTagsGalleryView(tags: tags(), counts: [:])
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

    func tags() -> [Post.Tag] {
        let data = TestData()
        try! data.loadData()

        var uniqueTags: Set<Post.Tag> = []
        var uniqueTagNames: Set<String> = []

        data.posts.forEach {
            $0.metadata.tags.forEach { tag in
                if uniqueTagNames.contains(tag.name) {
                    return
                }

                uniqueTagNames.insert(tag.name)
                uniqueTags.insert(tag)
            }
        }

        return Array(uniqueTags).sorted { $0.name < $1.name }
    }
}

struct SearchResultsView: View {
    let search: String

    init(for search: String) {
        self.search = search
    }

    var body: some View {
        Text("Search Results for: \(search)")
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
        .navigationTitle("Browse Post Per Tag")
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
