import SwiftUI
import Models

struct PostTagList: View {
    let tags: [Post.Tag]

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(tags) { tag in
                    NavigationLink(value: PostRoute.postsForTag(tag)) {
                        Text(tag.name)
                            .foregroundStyle(Color.white)
                            .font(.caption)
                            .bold()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(Color.indigo)
                            )
                    }
                    .navigationLinkIndicatorVisibility(.hidden)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PostTagList(tags: [.init(id: .init(), name: "foo"), .init(id: .init(), name: "bar")])
    }
    .padding()
}
