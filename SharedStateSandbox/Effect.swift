//
//  Effect.swift
//  SharedStateSandbox
//
//  Created by oantoniuk on 16.10.2024.
//

import Foundation
import ComposableArchitecture

//public protocol SharedStateAction {
//    static var sharedStateDidUpdate: Self { get }
//}

extension Effect {
    public static func syncSharedState<Value>(_ state: Shared<Value>, action: @escaping () -> Action) -> Effect<Action> {
        .run { send in
            for await _ in state.publisher.values {
                await send(action())
            }
        }
    }

// SWIFT 6
//    public static func syncSharedState<each Value, CancellationID: Hashable & Sendable>(_ states: (repeat Shared<each Value>), cancellationID: CancellationID, action: @escaping () -> Action) -> Effect<Action> {
//        if #available(iOS 17.0, *) {
//            return .none
//        } else {
//            return .run { send in
//                await withTaskGroup(of: Void.self) { group in
//                    for state in repeat (each states) {
//                        group.addTask {
//                            for await _ in state.publisher.values {
//                                await send(action())
//                            }
//                        }
//                    }
//                }
//            }
//            .cancellable(id: cancellationID, cancelInFlight: true)
//        }
//    }
}
