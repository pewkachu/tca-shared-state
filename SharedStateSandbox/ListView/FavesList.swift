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
        @Shared(.favoriteItemsStored) var favoriteStorage
    }
}
