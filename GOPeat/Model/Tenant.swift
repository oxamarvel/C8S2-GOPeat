//
//  Tenant.swift
//  GOPeat
//
//  Created by jonathan calvin sutrisna on 26/03/25.
//

import SwiftData
import Foundation

@Model
class Tenant: Identifiable {
    var id: UUID = UUID()
    var name: String
    var image: String
    var contactPerson: String
    var canteen: Canteen?
    var preorderInformation: Bool?
    var operationalHours: String
    var isHalal: Bool?
    var priceRange: String
    @Relationship(deleteRule: .cascade) var foods: [Food] = []
    init(name: String, image: String, contactPerson: String, preorderInformation:Bool?, operationalHours: String, isHalal: Bool?, canteen: Canteen?, priceRange: String) {
        self.name = name
        self.image = image
        self.contactPerson = contactPerson
        self.preorderInformation = preorderInformation
        self.operationalHours = operationalHours
        self.isHalal = isHalal
        self.canteen = canteen
        self.priceRange = priceRange
    }
}
