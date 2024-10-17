//
//  FavesListView.swift
//  SharedStateSandbox
//
//  Created by oantoniuk on 08.10.2024.
//

import ComposableArchitecture
import SwiftUI

struct FavesListView: View {
    struct ViewState: Equatable {
        let items: IdentifiedArrayOf<ItemModel>
//        let sharedID: UUID

        init(state: FavesList.State) {
            self.items = state.items.filter { state.favoriteItemsStorage.faves.contains($0.id) }
//            self.sharedID = state.sharedID
        }
    }

    let store: StoreOf<FavesList>
    @ObservedObject var viewStore: ViewStore<ViewState, FavesList.Action>

    init(store: StoreOf<FavesList>) {
        self.store = store
        self.viewStore = .init(store, observe: ViewState.init)
    }

    var body: some View {
        List {
            ForEach(viewStore.items) { item in
                ItemView(item: item, isFavorited: true, toggleFaves: nil)
            }
            .listStyle(.plain)
        }
//        .id(viewStore.sharedID)
        .onAppear {
            viewStore.send(.onAppear)
        }
    }
}

#Preview {
    FavesListView(store: Store(initialState: FavesList.State(items: .init(uniqueElements: ItemModel.mocks), favoriteItemsStorage: .init(faves: [])), reducer: {
        FavesList()
    }))
}
