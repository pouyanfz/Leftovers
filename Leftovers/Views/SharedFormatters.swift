//
//  SharedFormatters.swift
//  Leftovers
//
//  Created by Pouyan on 2025-08-25.
//


import Foundation

public enum SharedFormatters {
    public static let mediumDate: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()
}
