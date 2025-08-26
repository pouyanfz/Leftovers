//
//  SharedTheme.swift
//  Leftovers
//
//  Created by Pouyan on 2025-08-25.
//


import SwiftUI

public enum SharedTheme {
    public static let lowThreshold: Double = 0.30
    
    public static func progressColor(percent: Double) -> Color {
        switch percent {
        case ..<0.30: return .red
        case ..<0.60: return .yellow
        default: return .green
        }
    }
    
    public static func expirationTextColor(days: Int?) -> Color {
        guard let days = days else { return .gray }
        if days <= 0 { return .red }
        if days <= 7 { return .orange }
        return .gray
    }
    
    public static func expirationLabel(days: Int?) -> String {
        guard let days = days else { return "" }
        if days < 0 { return "Expired 🚨" }
        if days <= 7 { return "Expires soon ⚠️" }
        return "\(days) days left"
    }
}
