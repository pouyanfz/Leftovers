//
//  ExpirationAlertKind.swift
//  Leftovers
//
//  Created by Pouyan on 2025-08-26.
//


import UserNotifications
import Foundation

enum ExpirationAlertKind: String {
    case sevenDays = "7d"
    case onDay = "0d"
}

struct NotificationScheduler {

    static func requestAuthorizationIfNeeded() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            center.requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        }
    }

    static func scheduleExpirationAlerts(for item: Item) {
        // Only when tracking by expiration and a date exists
        guard item.dateMode == .expiration, let exp = item.expirationDate else {
            cancelExpirationAlerts(for: item)
            return
        }

        // Cancel old ones first
        cancelExpirationAlerts(for: item)

        let calendar = Calendar.current

        // Fire at 09:00 local time
        func components(for date: Date) -> DateComponents {
            var comps = calendar.dateComponents([.year, .month, .day], from: date)
            comps.hour = 9
            comps.minute = 0
            return comps
        }

        // Seven days before
        if let sevenDaysBefore = calendar.date(byAdding: .day, value: -7, to: exp),
           sevenDaysBefore >= Date() {
            let id = "expire_\(ExpirationAlertKind.sevenDays.rawValue)_\(item.id.uuidString)"
            let content = UNMutableNotificationContent()
            content.title = "Expiring soon"
            content.body = "\(item.name) expires in 7 days"
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: components(for: sevenDaysBefore), repeats: false)
            UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
        }

        // On the expiration day
        if exp >= Date() {
            let id = "expire_\(ExpirationAlertKind.onDay.rawValue)_\(item.id.uuidString)"
            let content = UNMutableNotificationContent()
            content.title = "Expires today"
            content.body = "\(item.name) expires today"
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: components(for: exp), repeats: false)
            UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
        }
    }

    static func cancelExpirationAlerts(for item: Item) {
        let ids = [
            "expire_\(ExpirationAlertKind.sevenDays.rawValue)_\(item.id.uuidString)",
            "expire_\(ExpirationAlertKind.onDay.rawValue)_\(item.id.uuidString)"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
    
    
    static func scheduleLowStockAlert(for item: Item) {
            let id = "lowstock_\(item.id.uuidString)"
            let content = UNMutableNotificationContent()
            content.title = "Low stock"
            content.body = "\(item.name) is below 30 percent"
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let req = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [id]) // de duplicate
            center.add(req)
        }

        static func cancelLowStockAlert(for item: Item) {
            let id = "lowstock_\(item.id.uuidString)"
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        }
}
