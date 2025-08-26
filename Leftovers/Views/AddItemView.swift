//
//  AddItemView.swift
//  Leftovers
//
//  Created by Pouyan on 2025-08-18.


import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ItemListViewModel
    @State private var name = ""
    @State private var count = ""
    @State private var unit = ""
    
    @State private var mode: DateMode = .none
    @State private var expirationDate = Date()
    @State private var purchaseDate = Date()
    
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Item name", text: $name)
                TextField("Count", text: $count)
                    .keyboardType(.numberPad)
                TextField("Unit (optional)", text: $unit)
                
                Picker("Track by", selection: $mode) {
                    Text("Expiration").tag(DateMode.expiration)
                    Text("Purchase").tag(DateMode.purchase)
                    Text("None").tag(DateMode.none)
                    
                }
                .pickerStyle(.segmented)
                
                switch mode {
                case .expiration:
                    DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date)
                case .purchase:
                    DatePicker("Purchase Date", selection: $purchaseDate, displayedComponents: .date)
                case .none:
                    EmptyView()
                }
                
            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let countInt = Int(count), !name.isEmpty {
                            let exp = mode == .expiration ? expirationDate : nil
                            let buy = mode == .purchase ? purchaseDate : nil
                            viewModel.addItem(
                                name: name,
                                count: countInt,
                                unit: unit.isEmpty ? nil : unit,
                                expirationDate: exp,
                                purchaseDate: buy,
                                dateMode: mode
                            )
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
