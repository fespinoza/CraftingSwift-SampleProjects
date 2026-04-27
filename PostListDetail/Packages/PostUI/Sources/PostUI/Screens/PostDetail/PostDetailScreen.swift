import SwiftUI
import Models

struct PostDetailScreen: View {
    let id: Post.ID
    @Environment(\.networkClient) private var networkClient

    @State private var loadingState: BasicLoadingState = .idle

    enum BasicLoadingState: Equatable {
        case idle
        case loading
        case dataLoaded(Post)
        case error(String)
    }

    var body: some View {
        ZStack {
            PostSceneBackground()

            switch loadingState {
            case .idle:
                Color.clear

            case .loading:
                ProgressView("Loading story")
                    .tint(PostPalette.accent)
                    .postSurface()
                    .padding(.horizontal, 20)

            case let .dataLoaded(post):
                PostDetailView(post: post)

            case .error(let error):
                ContentUnavailableView(
                    "Story Not Available",
                    systemImage: "newspaper.circle.fill",
                    description: Text(error)
                )
                .postSurface()
                .padding(.horizontal, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadPost() }
    }

    private func loadPost() async {
        guard case .idle = loadingState else { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            loadingState = .loading
        }

        do {
            let post = try await networkClient.fetchPost(id)

            withAnimation(.easeInOut(duration: 0.25)) {
                loadingState = .dataLoaded(post)
            }
        } catch {
            withAnimation(.easeInOut(duration: 0.25)) {
                loadingState = .error(error.localizedDescription)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PostDetailScreen(id: .init(.init(uuidString: "0ea79ff2-4a6f-48e3-8839-986414ad078f")!))
    }
}
