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
        @PresentationState var child: ListFeature.State?
    }

    enum Action {
        case navigate
        case toggleFavorite(id: ItemModel.ID)
        case toggleFaveView
        case child(PresentationAction<ListFeature.Action>)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .navigate:
                state.child = .init(items: state.items)
                return .none
                
            case let .toggleFavorite(id: id):
                state.favoriteStorage.toggle(fave: id)
                return .none

            case .toggleFaveView:
                state.favoriteStorage.filterByFaves.toggle()
                return .none

            case .child:
                return .none
            }
        }
        .ifLet(\.$child, action: \.child) {
            ListFeature()
        }
    }
}
