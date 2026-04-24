import SwiftUI
import Models

struct PostDetailScreen: View {
    let id: Post.ID

    @State var loadingState: BasicLoadingState = .idle

    enum BasicLoadingState: Equatable {
        case idle
        case loading
        case dataLoaded(Post)
        case error(String)
    }

    private let data = TestData()

    var body: some View {
        Group {
            switch loadingState {
            case .idle:
                Color.gray
            case .loading:
                ProgressView()
            case let .dataLoaded(post):
                PostDetailView(post: post)
            case .error(let error):
                Text(error)
                    .foregroundStyle(.red)
            }
        }
        .animation(.easeInOut, value: loadingState)
        .task {
            loadingState = .loading
            try? data.loadData()
            try? await Task.sleep(for: .seconds(2))

            if let post = data.posts.first(where: { $0.id == id }) {
                loadingState = .dataLoaded(post)
            } else {
                loadingState = .error("Post not found \(id)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        PostDetailScreen(id: .init(.init(uuidString: "0ea79ff2-4a6f-48e3-8839-986414ad078f")!))
    }
}
