import Foundation
import SwiftUI
import Models

enum CurrentUser {
    static let name = "Crafting Swift"
    static let id = UUID(uuidString: "1ab6bc51-27be-4e12-b086-ae926bdff421")!
    static let photoURL = URL(string: "https://i.pravatar.cc/150?img=17")!
}

public struct DemoContainer: View {
    @State private var isShowingUserProfile = false

    public init() {}

    public var body: some View {
        TabView {
            Tab("Posts", systemImage: "star") {
                NavigationStack {
                    PostListScreen(useCase: .allPosts)
                        .postDestinations()
                        .userProfileToolbar {
                            isShowingUserProfile = true
                        }
                }
            }

            Tab("Tags", systemImage: "tag") {
                NavigationStack {
                    PostTagsGalleryScreen()
                        .postDestinations()
                        .userProfileToolbar {
                            isShowingUserProfile = true
                        }
                }
            }
        }
        .sheet(isPresented: $isShowingUserProfile, content: {
            NavigationStack {
                VStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading) {
                        Text("Name")
                        Text(CurrentUser.name)
                    }

                    VStack(alignment: .leading) {
                        Text("ID")
                        Text(CurrentUser.id.uuidString)
                    }

                    Spacer()
                }
                .padding()
                .navigationTitle("Current User")
            }
            .presentationDetents([.medium])
        })
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

private extension View {
    func userProfileToolbar(showUserName: @escaping () -> Void) -> some View {
        toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: showUserName) {
                    Image(systemName: "person.crop.circle")
                }
                .accessibilityLabel("Show user name")
            }
        }
    }
}
