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

        init(state: ListFeature.State) {
            self.items = if state.filterByFaves {
                state.items.filter { state.faves.contains($0.id) }
            } else {
                state.items
            }
            self.favoriteItems = state.faves
            self.showFavoredOnly = state.filterByFaves
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
        .sheet(store: store.scope(state: \.$child, action: \.child)) { store in
            ListView(store: store)
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
    }
}

struct ItemView: View {
    let item: ItemModel
    let isFavorited: Bool
    var toggleFaves: (() ->  Void)?

    var body: some View {
        Text(item.title)
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background {
                Rectangle()
                    .fill(item.color)
            }
            .overlay(alignment: .topTrailing) {
                if let toggleFaves {
                    Button(action: {
                        toggleFaves()
                    }, label: {
                        Image(systemName: isFavorited ? "checkmark.square" : "square")
                    })
                    .tint(Color.white)
                }
            }
    }
}

#Preview {
    ListView(store: Store(initialState: ListFeature.State(items: .init(uniqueElements: ItemModel.mocks)), reducer: {
        ListFeature()
    }))
}
