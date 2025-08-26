//
//  SharedStore.swift
//  Leftovers
//
//  Created by Pouyan on 2025-08-19.
//

import Foundation

struct SharedStore {
    static let suiteName   = SharedKeys.suite
    static let itemsKey    = SharedKeys.itemsKey
    static let favoriteKey = SharedKeys.favoriteKey
    
    static var defaults: UserDefaults {
        guard let d = UserDefaults(suiteName: suiteName) else {
            assertionFailure("Missing App Group entitlement for \(suiteName)")
            return .standard   // keep this only to avoid a crash in Debug
        }
        return d
    }
    
    static func loadItems() -> [Item] {
        guard let data = defaults.data(forKey: itemsKey),
              let decoded = try? JSONDecoder().decode([Item].self, from: data) else { return [] }
        return decoded
    }
    
    static func favoriteId() -> UUID? {
        guard let s = defaults.string(forKey: favoriteKey) else { return nil }
        return UUID(uuidString: s)
    }
    
    // dev-only helper
    static func containerPath() -> String? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: suiteName)?
            .path
    }
}
