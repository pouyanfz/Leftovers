// ItemRowView.swift

import SwiftUI

struct ItemRowView: View {
    var item: Item 
    var onDecrement: () -> Void
    var onIncrement: () -> Void
    
    var body: some View {
        let tone = SharedTheme.progressColor(percent: item.percentageLeft)
        let expColor = SharedTheme.expirationTextColor(days: item.daysUntilExpiration)
        let dateText: String = {
            switch item.dateMode {
            case .expiration:
                if let d = item.expirationDate { return SharedFormatters.mediumDate.string(from: d) }
            case .purchase:
                if let d = item.purchaseDate { return SharedFormatters.mediumDate.string(from: d) }
                
            case .none:
                return ""}
            return ""
        }()
        let daysText: String = {
            switch item.dateMode {
            case .expiration:
                let label = SharedTheme.expirationLabel(days: item.daysUntilExpiration)
                return label.isEmpty ? "" : label
            case .purchase:
                if let n = item.daysSincePurchase {
                    return n == 0 ? "Purchased today" : "\(n) days ago"
                }
                return ""
            case .none:
                return ""
            }
        }()
        let textColor: Color = {
            switch item.dateMode {
            case .expiration:
                return SharedTheme.expirationTextColor(days: item.daysUntilExpiration)
            case .purchase, .none:
                return .gray
            }
        }()
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(expColor)
                
                ProgressView(value: item.percentageLeft)
                    .tint(tone)
                
                if !dateText.isEmpty || !daysText.isEmpty {
                    HStack(spacing: 6) {
                        let prefix = item.dateMode == .expiration ? "exp:" : "purchased:"
                        if !dateText.isEmpty {
                            Text("\(prefix) \(dateText)")
                                .font(.caption)
                                .foregroundColor(textColor)
                        }
                        if !dateText.isEmpty && !daysText.isEmpty {
                            Text("·")
                                .font(.caption)
                                .foregroundColor(textColor)
                        }
                        if !daysText.isEmpty {
                            Text(daysText)
                                .font(.caption)
                                .foregroundColor(textColor)
                        }
                    }
                }
                
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(item.count)")
                    .font(.title2).bold()
                    .monospacedDigit()
                if let unit = item.unit, !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Buttons side by side with clear hit areas
            VStack(spacing: 20) {
                Button(action: onDecrement) {
                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.red)
                        .contentShape(Rectangle())
                }
                
                Button(action: onIncrement) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.green)
                        .contentShape(Rectangle())
                }
            }
            .padding(.leading, 8)
        }
        .padding(.vertical, 6)
        .buttonStyle(BorderlessButtonStyle())
    }
}

#Preview {
    ItemListView()
}
