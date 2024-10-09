//
//  FavesList.swift
//  SharedStateSandbox
//
//  Created by oantoniuk on 08.10.2024.
//

import ComposableArchitecture
import Foundation

@Reducer
struct FavesList {
    struct State {
        var items: IdentifiedArrayOf<ItemModel>

        var faves: Set<ItemModel.ID> = []

        @Shared(.favoriteItemsStored) fileprivate var favoriteStorage

        mutating func syncSharedState(from state: FavoritesStore) {
            faves = state.faves
        }
    }

    enum Action {
        case onAppear
        case favoritesChanged(FavoritesStore)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.syncSharedState(from: state.favoriteStorage)
                return .publisher {
                    state.$favoriteStorage.publisher
                          .map(Action.favoritesChanged)
                }
            case .favoritesChanged(let store):
                state.syncSharedState(from: store)
                return .none
            }
        }
    }
}
