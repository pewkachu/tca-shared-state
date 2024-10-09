//
//  Models.swift
//  SharedStateSandbox
//
//  Created by oantoniuk on 08.10.2024.
//

import Foundation
import SwiftUI

struct ItemModel: Identifiable, Sendable, Hashable {
    let id: UUID
    let title: String
    let color: Color
}

// MARK: -
extension ItemModel {
    static let mocks: [Self] = [
        .init(id: .init(0), title: "Hello", color: .red),
        .init(id: .init(1), title: "World", color: .orange),
        .init(id: .init(2), title: "Fiz", color: .yellow),
        .init(id: .init(3), title: "Foo", color: .green),
        .init(id: .init(4), title: "Bar", color: .cyan),
        .init(id: .init(5), title: "John", color: .blue),
        .init(id: .init(6), title: "Doe", color: .purple)
    ]
}
