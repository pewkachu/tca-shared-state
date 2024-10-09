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

    @Shared(.favoriteItemsStored) private var favoriteStorage

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
//                state.syncSharedState(from: favoriteStorage)
                return .syncSharedState($favoriteStorage, action: Action.favoritesChanged)
//                return .run { send in
//                    for await state in $favoriteStorage.publisher.values {
//                        await send(.favoritesChanged(state))
//                    }
//                }
//                return .publisher {
//                    $favoriteStorage.publisher
//                          .map(Action.favoritesChanged)
//                }
            case .navigate:
                state.child = .init(items: state.items)
                return .none
                
            case let .toggleFavorite(id: id):
                favoriteStorage.toggle(fave: id)
                return .none

            case .toggleFaveView:
                favoriteStorage.filterByFaves.toggle()
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
