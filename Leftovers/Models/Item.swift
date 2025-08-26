//
//  Item.swift
//  Leftovers
//
//  Created by Pouyan on 2025-08-18.
//

import Foundation

enum DateMode: String, Codable, CaseIterable {
    case expiration
    case purchase
    case none
}

struct Item: Identifiable, Codable {
    let id: UUID
    var name: String
    var count: Int
    var startingCount: Int
    var unit: String?            // optional unit shown next to count
    var expirationDate: Date?    // optional expiration
    var purchaseDate: Date?
    var dateMode: DateMode = .none
    
    var percentageLeft: Double {
        guard startingCount > 0 else { return 0 }
        return Double(count) / Double(startingCount)
    }
    
    var daysUntilExpiration: Int? {
        guard let expirationDate else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let exp = calendar.startOfDay(for: expirationDate)
        return calendar.dateComponents([.day], from: today, to: exp).day
    }
    
    var daysSincePurchase: Int? {
        guard let purchaseDate else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let purchase = calendar.startOfDay(for: purchaseDate)
        return calendar.dateComponents([.day], from: purchase, to: today).day
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        count: Int,
        unit: String? = nil,
        expirationDate: Date? = nil,
        purchaseDate: Date? = nil,
        dateMode: DateMode = .expiration
    ) {
        self.id = id
        self.name = name
        self.count = count
        self.startingCount = count
        self.unit = unit
        self.expirationDate = expirationDate
        self.purchaseDate = purchaseDate
        self.dateMode = dateMode
    }
}
