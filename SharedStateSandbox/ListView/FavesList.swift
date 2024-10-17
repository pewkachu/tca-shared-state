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

        var sharedID: UUID
        @Shared var favoriteItemsStorage: FavoritesStorage<ItemModel.ID>

        mutating func sharedUpdated() {
            @Dependency(\.uuid) var uuid
            self.sharedID = uuid()
            print("FavesList.sharedUpdated", self.sharedID)
        }

        init(items: IdentifiedArrayOf<ItemModel>, favoriteItemsStorage: FavoritesStorage<ItemModel.ID> = .init(faves: [])) {
            self.items = items
            @Dependency(\.uuid) var uuid
            self.sharedID = uuid()
            self._favoriteItemsStorage = Shared(wrappedValue: favoriteItemsStorage, .favoriteItemsStorage)
        }
    }

    enum CancelID {
        case sharedSub
    }

    enum Action {
        case onAppear
        case sharedChanged
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if #available(iOS 17.0, *) {
                    return .none
                } else {
                    print("SUBSCRIBED")
                    return .syncSharedState(state.$favoriteItemsStorage, action: { Action.sharedChanged })
                        .cancellable(id: CancelID.sharedSub, cancelInFlight: true)
                }
//                return .syncSharedState(state.$favoriteItemsStorage, cancellationID: CancelID.sharedSub, action: { Action.sharedChanged })

            case .sharedChanged:
                state.sharedUpdated()
                return .none
            }
        }
    }
}
