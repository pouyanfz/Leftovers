//
//  AppIntent.swift
//  LeftoversWidget
//
//  Created by Pouyan on 2025-08-19.
//

// in the Widget extension target
import AppIntents
import WidgetKit

struct DecrementItemIntent: AppIntent {
    static var title: LocalizedStringResource = "Decrement Item"
    
    @Parameter(title: "Item Id")
    var itemId: String
    
    init() {}
    init(itemId: String) { self.itemId = itemId }
    
    func perform() async throws -> some IntentResult {
        let d = SharedStore.defaults
        let key = SharedStore.itemsKey
        
        guard let data = d.data(forKey: key),
              var items = try? JSONDecoder().decode([Item].self, from: data),
              let uid = UUID(uuidString: itemId),
              let index = items.firstIndex(where: { $0.id == uid }) else {
            return .result()
        }
        
        if items[index].count > 0 { items[index].count -= 1 }
        if let encoded = try? JSONEncoder().encode(items) {
            d.set(encoded, forKey: key)
        }
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
