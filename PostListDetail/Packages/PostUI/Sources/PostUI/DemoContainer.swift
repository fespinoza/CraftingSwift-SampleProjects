import SwiftUI
import Models

public struct DemoContainer: View {
    public init() {}

    public var body: some View {
        TabView {
            Tab("Feed", systemImage: "newspaper.fill") {
                NavigationStack {
                    PostListScreen(useCase: .allPosts)
                        .postDestinations()
                }
            }

            Tab("Discover", systemImage: "square.grid.2x2.fill") {
                NavigationStack {
                    PostSearchView()
                        .postDestinations()
                }
            }
        }
        .tint(PostPalette.accent)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.light, for: .tabBar)
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
