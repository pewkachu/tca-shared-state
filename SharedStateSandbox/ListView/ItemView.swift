//
//  ListItemView.swift
//  SharedStateSandbox
//
//  Created by oantoniuk on 17.10.2024.
//

import SwiftUI

struct ItemView: View {
    let item: ItemModel
    let isFavorited: Bool
    var toggleFaves: (() ->  Void)?

    var body: some View {
        Text(item.title)
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background {
                Rectangle()
                    .fill(item.color)
            }
            .overlay(alignment: .topTrailing) {
                if let toggleFaves {
                    Button(action: {
                        toggleFaves()
                    }, label: {
                        Image(systemName: isFavorited ? "checkmark.square" : "square")
                    })
                    .tint(Color.white)
                }
            }
    }
}
