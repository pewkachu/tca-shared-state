//
//  ListFeature.swift
//  SharedStateSandbox
//
//  Created by oantoniuk on 08.10.2024.
//

import ComposableArchitecture
import Foundation

@Reducer
struct ListFeature {
    struct State {
        var items: IdentifiedArrayOf<ItemModel>
        @Shared(.favoriteItemsStored) var favoriteStorage
    }

    enum Action {
        case toggleFavorite(id: ItemModel.ID)
        case toggleFaveView
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .toggleFavorite(id: id):
                if state.favoriteStorage.faves.contains(id) {
                    state.favoriteStorage.faves.remove(id)
                } else {
                    state.favoriteStorage.faves.insert(id)
                }
                return .none

            case .toggleFaveView:
                state.favoriteStorage.filterByFaves.toggle()
                return .none
            }
        }
    }
}
