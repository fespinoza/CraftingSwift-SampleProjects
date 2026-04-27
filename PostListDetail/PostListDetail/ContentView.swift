//
//  ContentView.swift
//  PostListDetail
//
//  Created by Felipe Espinoza on 15/04/2026.
//

import SwiftUI
#if canImport(PostUI)
import PostUI
#endif

struct ContentView: View {
    var body: some View {
#if canImport(PostUI)
        DemoContainer()
#else
        ContentUnavailableView(
            "PostUI Not Linked",
            systemImage: "shippingbox",
            description: Text("Add the local PostUI package to the app target to launch the redesigned experience.")
        )
#endif
    }
}

#Preview {
    ContentView()
}
