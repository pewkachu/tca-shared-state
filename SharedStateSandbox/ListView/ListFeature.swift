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
    struct State: Equatable {
        var items: IdentifiedArrayOf<ItemModel>
        
        var faves: Set<ItemModel.ID> = []
        var filterByFaves: Bool = false

        @PresentationState var child: ListFeature.State?

        mutating func syncFavoritesState(from state: FavoritesStorage<ItemModel.ID>) {
            faves = state.faves
        }

        mutating func syncSharedState(from state: SharedStore) {
            filterByFaves = state.filterByFaves
        }
    }

    enum Action: Equatable {
        case onAppear
        case navigate
        case toggleFavorite(id: ItemModel.ID)
        case toggleFaveView
        case child(PresentationAction<ListFeature.Action>)

        // MARK: - Shared
        case sharedSub
        case sharedUnsub
        case sharedUpdateFaves(FavoritesStorage<ItemModel.ID>)
        case sharedUpdateSharedStore(SharedStore)
    }

    @Shared private var sharedStorage: SharedStore
    @Shared private var favoriteItemsStorage: FavoritesStorage<ItemModel.ID>

    init(
        sharedStorage: Shared<SharedStore> = Shared(wrappedValue: SharedStore(filterByFaves: false), .sharedStorage),
        favoriteItemsStorage: Shared<FavoritesStorage<ItemModel.ID>> = Shared(wrappedValue: FavoritesStorage(faves: []), .favoriteItemsStorage)
    ) {
        self._sharedStorage = sharedStorage
        self._favoriteItemsStorage = favoriteItemsStorage
    }

    enum CancellationID {
        case subscriptions
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.sharedSub)

            case .navigate:
                state.child = .init(items: state.items)
                return .none
                
            case let .toggleFavorite(id: id):
                favoriteItemsStorage.toggle(fave: id)
                return .none

            case .toggleFaveView:
                sharedStorage.filterByFaves.toggle()
                return .none

            case .child:
                return .none

            // MARK: - Shared Actions
            case .sharedUpdateFaves(let store):
                state.syncFavoritesState(from: store)
                return .none

            case .sharedUpdateSharedStore(let store):
                state.syncSharedState(from: store)
                return .none

            case .sharedSub:
                return .merge(
                    .syncSharedState($favoriteItemsStorage, action: Action.sharedUpdateFaves),
                    .syncSharedState($sharedStorage, action: Action.sharedUpdateSharedStore)
                )
                .cancellable(id: CancellationID.subscriptions)

            case .sharedUnsub:
                return .cancel(id: CancellationID.subscriptions)
            }
        }
        .ifLet(\.$child, action: \.child) {
            ListFeature()
        }
    }
}

extension Effect {
    public static func syncSharedState<Value>(_ state: Shared<Value>, action: @escaping (Value) -> Action) -> Effect<Action> {
        .run { send in
            await send(action(state.wrappedValue))
            for await state in state.publisher.values {
                await send(action(state))
            }
        }
    }
}
