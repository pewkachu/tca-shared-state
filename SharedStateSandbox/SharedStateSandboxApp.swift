//
//  SharedStateSandboxApp.swift
//  SharedStateSandbox
//
//  Created by oantoniuk on 08.10.2024.
//

import ComposableArchitecture
import SwiftUI

@main
struct SharedStateSandboxApp: App {
    let store1 = Store(initialState: ListFeature.State(items: .init(uniqueElements: ItemModel.mocks)), reducer: {
        ListFeature()
    })

    let store2 = Store(initialState: ListFeature.State(items: .init(uniqueElements: ItemModel.mocks)), reducer: {
        ListFeature()
    })
    var body: some Scene {
        WindowGroup {
            TabView {
                ListView(store: store1)
                    .tabItem { Text("Tab 1") }

                ListView(store: store2)
                    .tabItem { Text("Tab 2") }

                NavigationStack {
                    FavesListView(store: Store(initialState: FavesList.State(items: .init(uniqueElements: ItemModel.mocks)), reducer: {
                        FavesList()
                    }))
                    .navigationTitle("Favorites")
                }
                .tabItem { Text("Faves") }
            }
        }
    }
}
