//
//  ListFeature.swift
//  SharedStateSandbox
//
//  Created by oantoniuk on 08.10.2024.
//

import ComposableArchitecture
import Dependencies
import Foundation

@Reducer
struct ListFeature {
    struct State: Equatable {
        var items: IdentifiedArrayOf<ItemModel>
        @PresentationState var child: ListFeature.State?

        // MARK: - Shared
        @Shared var sharedStorage: SharedStore
        @Shared var favoriteItemsStorage: FavoritesStorage<ItemModel.ID>

        // MARK: -

        init(items: IdentifiedArrayOf<ItemModel>, child: ListFeature.State? = nil, sharedStorage: SharedStore = .init(filterByFaves: false), favoriteItemsStorage: FavoritesStorage<ItemModel.ID> = .init(faves: [])) {
            self.items = items
            self.child = child

            self._sharedStorage = Shared(wrappedValue: sharedStorage, .sharedStorage)
            self._favoriteItemsStorage = Shared(wrappedValue: favoriteItemsStorage, .favoriteItemsStorage)
        }
    }

    enum Action: Equatable, IOS16SharedStateAction {
        case onAppear
        case navigate
        case toggleFavorite(id: ItemModel.ID)
        case toggleFaveView
        case child(PresentationAction<ListFeature.Action>)

        case sharedSub
        case _sharedStateDidUpdate
    }

    enum CancellationID {
        case sharedSub
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.sharedSub)

            case .navigate:
                state.child = state
                return .none
                
            case let .toggleFavorite(id: id):
                state.favoriteItemsStorage.toggle(fave: id)
                return .none

            case .toggleFaveView:
                state.sharedStorage.filterByFaves.toggle()
                return .none

            case .child:
                return .none

            // MARK: - Shared Actions
            case .sharedSub:
                if #available(iOS 17.0, *) {
                    return .none
                } else {
                    print("SUBSCRIBED")
                    return .merge(
                        .syncSharedState(state.$sharedStorage),
                        .syncSharedState(state.$favoriteItemsStorage)
                    ).cancellable(id: CancellationID.sharedSub, cancelInFlight: true)
                }
//                return .syncSharedState((state.$sharedStorage, state.$favoriteItemsStorage), cancellationID: CancellationID.sharedSub)

            case ._sharedStateDidUpdate:
                return .none
            }
        }
        .ifLet(\.$child, action: \.child) {
            ListFeature()
        }
    }
}
