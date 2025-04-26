//
//  Item.swift
//  PokeApp
//
//  Created by Kai Oishi on 2025/04/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
