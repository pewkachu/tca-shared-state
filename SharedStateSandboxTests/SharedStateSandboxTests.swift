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
        let store = await TestStore(initialState: ListFeature.State(items: .init()), reducer: { ListFeature() }) {
            $0.uuid = .incrementing
        }

        // actions
        await store.send(.toggleFaveView) {
            $0.sharedStorage.filterByFaves = true
        }
    }
}
