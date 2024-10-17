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

        @Shared var favoriteItemsStorage: FavoritesStorage<ItemModel.ID>

        init(items: IdentifiedArrayOf<ItemModel>, favoriteItemsStorage: FavoritesStorage<ItemModel.ID> = .init(faves: [])) {
            self.items = items
            self._favoriteItemsStorage = Shared(wrappedValue: favoriteItemsStorage, .favoriteItemsStorage)
        }
    }

    enum CancelID {
        case sharedSub
    }

    enum Action: IOS16SharedStateAction {
        case onAppear
        case _sharedStateDidUpdate
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if #available(iOS 17.0, *) {
                    return .none
                } else {
                    print("SUBSCRIBED")
                    return .syncSharedState(state.$favoriteItemsStorage)
                        .cancellable(id: CancelID.sharedSub, cancelInFlight: true)
                }
//                return .syncSharedState(state.$favoriteItemsStorage, cancellationID: CancelID.sharedSub)

            case ._sharedStateDidUpdate:
                return .none
            }
        }
    }
}
