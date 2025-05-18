//
//  Food.swift
//  GOPeat
//
//  Created by jonathan calvin sutrisna on 26/03/25.
//

import Foundation
import SwiftData

@Model
class Food: Identifiable {
    var id: UUID = UUID()
    var name: String
    var desc: String
    var tenant: Tenant?
    var categories: [FoodCategory] = []
    init(name: String, description: String, categories: [FoodCategory], tenant: Tenant?) {
        self.name = name
        self.desc = description
        self.categories = categories
        self.tenant = tenant
    }
}

enum FoodCategory: String, CaseIterable, Codable {
    case spicy = "Spicy"
    case nonSpicy = "Non-Spicy"
    case soup = "Soup"
    case greasy = "Greasy"
    case nonGreasy = "Non-Greasy"
    case roast = "Roast"
    case savory = "Savory"
    case sweet = "Sweet"
    case nonSweet = "Non-Sweet"
}
