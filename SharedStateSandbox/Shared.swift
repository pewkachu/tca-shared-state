//
//  Shared.swift
//  SharedStateSandbox
//
//  Created by oantoniuk on 08.10.2024.
//

import ComposableArchitecture
import Foundation

struct FavoritesStore: Codable {
    var filterByFaves: Bool
    var faves: Set<ItemModel.ID>

    mutating func toggle(fave: ItemModel.ID) {
        if faves.contains(fave) {
            faves.remove(fave)
        } else {
            faves.insert(fave)
        }
    }

    init(filterByFaves: Bool, faves: Set<ItemModel.ID>) {
        self.filterByFaves = filterByFaves
        self.faves = faves
    }
}

extension PersistenceReaderKey where Self == InMemoryKey<FavoritesStore> {
    static var favoriteItems: Self {
        inMemory("favoriteItems")
    }
}

extension URL {
    static let favesStorage: URL = URL.documentsDirectory.appending(path: "faves.json")
}

extension PersistenceReaderKey where Self == PersistenceKeyDefault<FileStorageKey<FavoritesStore>> {
    static var favoriteItemsStored: Self {
        PersistenceKeyDefault(.fileStorage(.favesStorage), .init(filterByFaves: false, faves: []))
    }
}

