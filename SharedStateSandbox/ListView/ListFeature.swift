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
        
        var faves: Set<ItemModel.ID> = []
        var filterByFaves: Bool = false

        @Shared(.favoriteItemsStored) fileprivate var favoriteStorage
        @PresentationState var child: ListFeature.State?

        mutating func syncSharedState(from state: FavoritesStore) {
            faves = state.faves
            filterByFaves = state.filterByFaves
        }
    }

    enum Action {
        case onAppear
        case navigate
        case toggleFavorite(id: ItemModel.ID)
        case toggleFaveView
        case child(PresentationAction<ListFeature.Action>)
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

            case .favoritesChanged(let store):
                state.syncSharedState(from: store)
                return .none
            }
        }
        .ifLet(\.$child, action: \.child) {
            ListFeature()
        }
    }
}
