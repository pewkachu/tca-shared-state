//
//  Shared.swift
//  SharedStateSandbox
//
//  Created by oantoniuk on 08.10.2024.
//

import ComposableArchitecture
import Foundation

extension URL {
    static let sharedStorage: URL = URL.documentsDirectory.appending(path: "shared.json")
}

extension PersistenceReaderKey where Self == PersistenceKeyDefault<FileStorageKey<SharedStore>> {
    static var sharedStorage: Self {
        PersistenceKeyDefault(.fileStorage(.sharedStorage), .init(filterByFaves: false))
    }
}

struct SharedStore: Codable {
    var filterByFaves: Bool

    init(filterByFaves: Bool) {
        self.filterByFaves = filterByFaves
    }
}

// ---------
extension PersistenceReaderKey where Self == InMemoryKey<FavoritesStorage<ItemModel.ID>> {
    static var favoriteItems: Self {
        inMemory("favoriteItems")
    }
}

extension URL {
    static let favesStorage: URL = URL.documentsDirectory.appending(path: "faves.json")
}

extension PersistenceReaderKey where Self == PersistenceKeyDefault<FileStorageKey<FavoritesStorage<ItemModel.ID>>> {
    static var favoriteItemsStorage: Self {
        PersistenceKeyDefault(.fileStorage(.favesStorage), .init(faves: []))
    }
}

struct FavoritesStorage<IDType: Hashable & Codable>: Codable {
    var faves: Set<IDType>

    mutating func toggle(fave: IDType) {
        if faves.contains(fave) {
            faves.remove(fave)
        } else {
            faves.insert(fave)
        }
    }

    init(faves: Set<IDType>) {
        self.faves = faves
    }
}
