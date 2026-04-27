import SwiftUI
import Models

struct DemoContainer: View {
    var body: some View {
        TabView {
            Tab("Posts", systemImage: "star") {
                NavigationStack {
                    PostListScreen(useCase: .allPosts)
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
                PostListScreen(useCase: .allPosts)
            case let .postsForTag(tag):
                PostListScreen(useCase: .postForTag(tag))
            }
        }
    }
}
