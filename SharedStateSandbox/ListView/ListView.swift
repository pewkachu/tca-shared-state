//
//  ListView.swift
//  SharedStateSandbox
//
//  Created by oantoniuk on 08.10.2024.
//

import ComposableArchitecture
import SwiftUI

struct ListView: View {
    struct ViewState: Equatable {
        let items: IdentifiedArrayOf<ItemModel>
        let favoriteItems: Set<ItemModel.ID>
        let showFavoredOnly: Bool
//        let sharedID: UUID

        init(state: ListFeature.State) {
            self.items = if state.sharedStorage.filterByFaves {
                state.items.filter { state.favoriteItemsStorage.faves.contains($0.id) }
            } else {
                state.items
            }
            self.favoriteItems = state.favoriteItemsStorage.faves
            self.showFavoredOnly = state.sharedStorage.filterByFaves
//            self.sharedID = state.sharedID
        }
    }

    let store: StoreOf<ListFeature>
    @ObservedObject var viewStore: ViewStore<ViewState, ListFeature.Action>

    init(store: StoreOf<ListFeature>) {
        self.store = store
        self.viewStore = .init(store, observe: ViewState.init)
    }

    var body: some View {
        List {
            HStack(spacing: 20) {
                Button("Push") {
                    viewStore.send(.navigate)
                }
                .buttonStyle(.plain)

                Toggle(isOn: viewStore.binding(get: \.showFavoredOnly, send: { _ in .toggleFaveView }), label: {
                    Text("Show faves only:")
                })
            }
            ForEach(viewStore.items) { item in
                ItemView(item: item, isFavorited: viewStore.favoriteItems.contains(item.id)) {
                    viewStore.send(.toggleFavorite(id: item.id))
                }
            }
            .listStyle(.plain)
        }
//        .id(viewStore.sharedID)
        .sheet(store: store.scope(state: \.$child, action: \.child)) { store in
            ListView(store: store)
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
    }
}

#Preview {
    ListView(store: Store(initialState: ListFeature.State(items: .init(uniqueElements: ItemModel.mocks), sharedStorage: .init(filterByFaves: false), favoriteItemsStorage: .init(faves: [])), reducer: {
        ListFeature()
    }))
}
