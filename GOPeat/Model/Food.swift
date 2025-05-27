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
    case nonSpicy = "Non-Spicy"
    case spicy = "Spicy"
    
    case nonGreasy = "Non-Greasy"
    case greasy = "Greasy"
    
    case nonSweet = "Non-Sweet"
    case sweet = "Sweet"

    case dairyFree = "Dairy-Free"
    case crustaceanFree = "Crustacean-Free"
    
    
    
    case savory = "Savory"
    case soup = "Soup"
    case roast = "Roast"
}
