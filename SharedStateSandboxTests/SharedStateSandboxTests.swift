//
//  SharedStateSandboxTests.swift
//  SharedStateSandboxTests
//
//  Created by oantoniuk on 14.10.2024.
//

@testable import SharedStateSandbox
import ComposableArchitecture
import XCTest

final class SharedStateSandboxTests: XCTestCase {

    func testListFeature() async {
        let filter = Shared(SharedStore(filterByFaves: false))
        let faves = Shared(FavoritesStorage<ItemModel.ID>(faves: []))
        let store = await TestStore(initialState: ListFeature.State(items: .init()), reducer: { ListFeature(sharedStorage: filter, favoriteItemsStorage: faves) })

        await store.send(.subscribeShared)
        await store.receive(\.favoritesChanged, faves.wrappedValue)
        await store.receive(\.sharedChanged, filter.wrappedValue)

        await store.send(.toggleFaveView)
        await store.receive(\.sharedChanged, filter.wrappedValue) {
            $0.filterByFaves = true
        }

        await store.send(.cancelSharedSubscriptions)
    }
}
