//
//  ItemListViewModel.swift
//  Leftovers
//
//  Created by Pouyan on 2025-08-18.
//

import Foundation

class ItemListViewModel: ObservableObject {
    @Published var items: [Item] = []
    private let itemsKey = "trackedItems"
    
    init() {
        loadItems()
    }
    
    func addItem(name: String, count: Int, expirationDate: Date? = nil) {
        let newItem = Item(name: name, count: count, expirationDate: expirationDate)
        items.append(newItem)
        saveItems()
    }
    
    func decrementItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            if items[index].count > 0 {
                items[index].count -= 1
                saveItems()
                print("Decremented \(item.name) → \(items[index].count)")
            }
        }
    }
    
    func incrementItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            if items[index].count < items[index].startingCount {
                items[index].count += 1
                saveItems()
                print("Incremented \(item.name) → \(items[index].count)")
            }
        }
    }
    
    func setItemCount(_ item: Item, to value: Int) {
            if let index = items.firstIndex(where: { $0.id == item.id }) {
                items[index].count = max(0, value)
            }
        }
    
    func setExpirationDate(_ item: Item, to date: Date?) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].expirationDate = date
        }
    }
    
    
    func deleteItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        saveItems()
    }
    
    // MARK: - Persistence
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: itemsKey)
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: itemsKey),
           let decoded = try? JSONDecoder().decode([Item].self, from: data) {
            items = decoded
        }
    }
}
