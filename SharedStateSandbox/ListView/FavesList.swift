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

        mutating func syncSharedState(from state: FavoritesStorage<ItemModel.ID>) {
            faves = state.faves
        }
    }

    @Shared(.favoriteItemsStorage) private var favoriteItemsStorage

    enum Action {
        case onAppear
        case favoritesChanged(FavoritesStorage<ItemModel.ID>)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .syncSharedState($favoriteItemsStorage, action: Action.favoritesChanged)
//                state.syncSharedState(from: favoriteStorage)
//                return .run { send in
//                    for await state in $favoriteStorage.publisher.values {
//                        await send(.favoritesChanged(state))
//                    }
//                }
//                return .publisher {
//                    $favoriteStorage.publisher
//                          .map(Action.favoritesChanged)
//                }
            case .favoritesChanged(let store):
                state.syncSharedState(from: store)
                return .none
            }
        }
    }
}
