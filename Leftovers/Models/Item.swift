//
//  Item.swift
//  Leftovers
//
//  Created by Pouyan on 2025-08-18.
//

import Foundation

struct Item: Identifiable, Codable {
    let id: UUID
    var name: String
    var count: Int
    var startingCount: Int
    var unit: String?
    var expirationDate: Date?
    
    var percentageLeft: Double {
        guard startingCount > 0 else { return 0 }
        return Double(count) / Double(startingCount)
    }
    
    var daysUntilExpiration: Int? {
        guard let expirationDate else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let exp = calendar.startOfDay(for: expirationDate)
        let diff = calendar.dateComponents([.day], from: today, to: exp).day
        return diff
    }
    
    init(name: String, count: Int, expirationDate: Date? = nil) {
        self.id = UUID()
        self.name = name
        self.count = count
        self.startingCount = count
        self.expirationDate = expirationDate
    }
}
