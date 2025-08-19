//
//  ItemListView.swift
//  Leftovers
//
//  Created by Pouyan on 2025-08-18.
import SwiftUI

struct ItemListView: View {
    @StateObject var viewModel = ItemListViewModel()
    @State private var showingAddItem = false

    // refill state
    @State private var refillTarget: Item? = nil
    @State private var refillAmount: String = ""
    @State private var refillDate: Date? = nil
    @State private var showingRefillSheet = false

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.items) { item in
                    ItemRowView(
                        item: item,
                        onDecrement: { viewModel.decrementItem(item) },
                        onIncrement: { viewModel.incrementItem(item) }
                    )
                    .swipeActions(edge: .leading) {
                        Button {
                            refillTarget = item
                            refillAmount = "\(item.count)" // prefill
                            refillDate = item.expirationDate
                        } label: {
                            Label("Refill", systemImage: "arrow.clockwise")
                        }
                        .tint(.blue)
                    }
                }
                .onDelete(perform: viewModel.deleteItem)
            }
            .navigationTitle("My Items")
            .toolbar {
                Button(action: { showingAddItem = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView(viewModel: viewModel)
            }
            // refill sheet
            .sheet(item: $refillTarget) { target in
                VStack(spacing: 20) {
                    Text("Refill \(target.name)")
                        .font(.headline)

                    TextField("Enter new count", text: $refillAmount)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    DatePicker(
                        "Expiration Date (optional)",
                        selection: Binding(
                            get: { refillDate ?? Date() },
                            set: { refillDate = $0 }
                        ),
                        displayedComponents: [.date]
                    )
                    .padding()

                    HStack {
                        Button("Cancel") {
                            refillTarget = nil
                        }
                        Spacer()
                        Button("Save") {
                            if let value = Int(refillAmount) {
                                viewModel.setItemCount(target, to: value)
                                viewModel.setExpirationDate(target, to: refillDate)
                            }
                            refillTarget = nil
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            }
        }
}
