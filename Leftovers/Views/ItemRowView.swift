import SwiftUI

import SwiftUI

struct ItemRowView: View {
    var item: Item
    var onDecrement: () -> Void
    var onIncrement: () -> Void
    
    private var barColor: Color {
        switch item.percentageLeft {
        case ..<0.25: return .red
        case ..<0.5: return .yellow
        default: return .green
        }
    }
    
    private var expirationTextColor: Color {
        if let days = item.daysUntilExpiration {
            if days < 0 {
                return .red
            } else if days == 0 {
                return .red
            } else if days <= 7 {
                return .orange
            } else {
                return .gray
            }
        }
        return .gray
    }

    
    private var expirationText: String {
        if let days = item.daysUntilExpiration {
            if days < 0 {
                return "Expired"
            } else if days == 0 {
                return "Expires today"
            } else {
                return "\(days) days left"
            }
        }
        return ""
    }
    
    private var formattedDate: String {
        if let expDate = item.expirationDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: expDate)
        }
        return ""
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(expirationTextColor)

                ProgressView(value: item.percentageLeft)
                    .progressViewStyle(LinearProgressViewStyle(tint: barColor))
                
                if item.expirationDate != nil {
                    HStack {
                        Text(formattedDate)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        if !expirationText.isEmpty {
                            Text("· \(expirationText)")
                                .font(.caption)
                                .foregroundColor(expirationTextColor)
                        }
                    }
                }

            }
            
            Spacer()
            
            Text("\(item.count)\(item.unit != nil ? " \(item.unit!)" : "")")
                .font(.title2)
            
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
        .buttonStyle(BorderlessButtonStyle()) // avoids List row hijacking taps
    }
}

#Preview {
    ItemListView()
}
