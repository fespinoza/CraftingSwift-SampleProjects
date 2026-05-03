import SwiftUI
import Models

public struct DemoContainer: View {
    public init() {}

    public var body: some View {
        TabView {
            Tab("Posts", systemImage: "star") {
                NavigationStack {
                    PostListScreen(useCase: .allPosts)
                        .postDestinations()
                }
            }

            Tab("Tags", systemImage: "tag") {
                NavigationStack {
                    PostTagsGalleryScreen()
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
