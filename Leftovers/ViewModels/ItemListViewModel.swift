//
//  ItemListViewModel.swift
//  Leftovers
//
//  Created by Pouyan on 2025-08-18.
//

import Combine
import Foundation
import WidgetKit
import SwiftUI

class ItemListViewModel: ObservableObject {
    @Published var items: [Item] = []
    
    private let defaults = SharedStore.defaults
    private let itemsKey = SharedKeys.itemsKey
    private let favoriteKey = SharedKeys.favoriteKey
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // sanity logs so you know you are actually in the App Group
        print("App Group suite: \(SharedKeys.suite)")
        print("App Group container: \(SharedStore.containerPath() ?? "nil")")
        loadItems()
        NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .receive(on: DispatchQueue.main) // Ensures we are on the main thread
            .sink { [weak self] _ in
                print("Received UserDefaults didChangeNotification. Reloading items.")
                self?.loadItems()
            }
            .store(in: &cancellables)
        
        
        NotificationCenter.default
            .publisher(for: UIScene.willEnterForegroundNotification) // In UIKit, you would use UIApplication.willEnterForegroundNotification
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("App will enter foreground. Reloading items.")
                self?.loadItems()
            }
            .store(in: &cancellables)
    }
    
    func addItem(
        name: String,
        count: Int,
        unit: String? = nil,
        expirationDate: Date? = nil,
        purchaseDate: Date? = nil,
        dateMode: DateMode = .none
    ) {
        let newItem = Item(
            name: name,
            count: count,
            unit: unit,
            expirationDate: expirationDate,
            purchaseDate: purchaseDate,
            dateMode: dateMode
        )
        items.append(newItem)
        saveItems()
        NotificationScheduler.scheduleExpirationAlerts(for: newItem)
    }
    func decrementItem(_ item: Item) {
        guard let i = items.firstIndex(where: { $0.id == item.id }) else { return }
        let before = items[i]
        if items[i].count > 0 {
            items[i].count -= 1
            let after = items[i]
            saveItems()
            handleLowStockTransition(old: before, new: after)
        }
    }
    
    func incrementItem(_ item: Item) {
        guard let i = items.firstIndex(where: { $0.id == item.id }) else { return }
        let before = items[i]
        if items[i].count < items[i].startingCount {
            items[i].count += 1
            let after = items[i]
            saveItems()
            handleLowStockTransition(old: before, new: after)
        }
    }
    
    func setItemCount(_ item: Item, to value: Int, resetBaseline: Bool = true) {
        guard let i = items.firstIndex(where: { $0.id == item.id }) else { return }
        let before = items[i]
        let v = max(0, value)
        if resetBaseline { items[i].startingCount = max(1, v) }
        items[i].count = v
        let after = items[i]
        saveItems()
        handleLowStockTransition(old: before, new: after)
    }
    
    func setExpirationDate(_ item: Item, to date: Date?) {
        if let i = items.firstIndex(where: { $0.id == item.id }) {
            items[i].expirationDate = date
            saveItems()
            NotificationScheduler.scheduleExpirationAlerts(for: items[i])
        }
    }
    
    func setPurchaseDate(_ item: Item, to date: Date?) {
        if let i = items.firstIndex(where: { $0.id == item.id }) {
            items[i].purchaseDate = date
            saveItems()
            NotificationScheduler.scheduleExpirationAlerts(for: items[i])
        }
    }
    
    func favoriteId() -> UUID? {
        if let s = defaults.string(forKey: favoriteKey) {
            return UUID(uuidString: s)
        }
        return nil
    }
    
    func favoriteItem() -> Item? {
        guard let fid = favoriteId() else { return nil }
        return items.first(where: { $0.id == fid })
    }
    
    func deleteItem(at offsets: IndexSet) {
        for index in offsets {
            NotificationScheduler.cancelExpirationAlerts(for: items[index])
            NotificationScheduler.cancelLowStockAlert(for: items[index])
        }
        items.remove(atOffsets: offsets)
        saveItems()
    }
    
    func setFavorite(_ item: Item) {
        print("Entered setFavorite()\n")
        defaults.set(item.id.uuidString, forKey: favoriteKey)
        WidgetCenter.shared.reloadAllTimelines()
        print("Favorite set to \(item.name) [\(item.id.uuidString)]")
        print(
            "Saved favorite id = \(defaults.string(forKey: favoriteKey) ?? "nil")"
        )
    }
    
    func refillItem(
        _ item: Item,
        add amount: Int,
        dateMode: DateMode,
        expirationDate: Date?,
        purchaseDate: Date?
    ) {
        guard amount > 0, let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        let before = items[idx]
        
        // Increase count and baseline so the progress bar reflects a full restock
        items[idx].count += amount
        items[idx].startingCount += amount
        
        // Update date mode and dates
        items[idx].dateMode = dateMode
        switch dateMode {
        case .expiration:
            items[idx].expirationDate = expirationDate
            items[idx].purchaseDate = nil
        case .purchase:
            items[idx].purchaseDate = purchaseDate
            items[idx].expirationDate = nil
        case .none:
            items[idx].purchaseDate = nil
            items[idx].expirationDate = nil
        }
        let after = items[idx]
        NotificationScheduler.scheduleExpirationAlerts(for: items[idx])
        saveItems()
        handleLowStockTransition(old: before, new: after)
    }
    
    
    // MARK: - Persistence
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            defaults.set(encoded, forKey: itemsKey)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    private func loadItems() {
        if let data = defaults.data(forKey: itemsKey),
           let decoded = try? JSONDecoder().decode([Item].self, from: data) {
            items = decoded
            print("Items reloaded. Count: \(items.count)")
        }
    }
    
    private func handleLowStockTransition(old: Item, new: Item) {
        let wasLow = old.percentageLeft < SharedTheme.lowThreshold
        let isLow  = new.percentageLeft < SharedTheme.lowThreshold
        
        if !wasLow && isLow {
            NotificationScheduler.scheduleLowStockAlert(for: new)
        } else if wasLow && !isLow {
            NotificationScheduler.cancelLowStockAlert(for: new)
        }
    }
    
}
