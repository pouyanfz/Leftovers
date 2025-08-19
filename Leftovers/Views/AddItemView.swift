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
    @State private var hasExpirationDate = false
    @State private var expirationDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Item name", text: $name)
                TextField("Count", text: $count)
                    .keyboardType(.numberPad)
                TextField("Unit (optional)", text: $unit)
                
                Toggle("Set expiration date", isOn: $hasExpirationDate)
                if hasExpirationDate {
                    DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let countInt = Int(count), !name.isEmpty {
                            viewModel.addItem(
                                name: name,
                                count: countInt,
                                expirationDate: hasExpirationDate ? expirationDate : nil
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
