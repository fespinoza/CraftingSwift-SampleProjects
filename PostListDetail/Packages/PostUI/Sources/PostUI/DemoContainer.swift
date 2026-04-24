import SwiftUI
import Models

struct DemoContainer: View {
    var body: some View {
        TabView {
            Tab("Posts", systemImage: "star") {
                NavigationStack {
                    PostList(title: "All Posts")
                        .postDestinations()
                }
            }

            Tab("Search", systemImage: "magnifyingglass") {
                NavigationStack {
                    PostSearchView()
                        .postDestinations()
                }
            }
        }
    }
}

#Preview {
    DemoContainer()
}

extension View {
    func postDestinations() -> some View {
        navigationDestination(for: PostRoute.self) { route in
            switch route {
            case let .post(id):
                PostDetailScreen(id: id)
            case .allPosts:
                PostList(title: "All Posts")
            case let .postsForTag(tag):
                PostList(tag: tag)
            }
        }
    }
}
