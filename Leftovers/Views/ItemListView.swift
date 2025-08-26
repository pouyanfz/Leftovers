//
//  ItemListView.swift
//  Leftovers
//
//  Created by Pouyan on 2025-08-18.
import SwiftUI

struct ItemListView: View {
    @StateObject var viewModel = ItemListViewModel()
    @State private var showingAddItem = false
    @State private var showingFavoriteAlert = false
    @State private var favoriteName = ""
    
    // refill state
    @State private var refillTarget: Item? = nil
    @State private var refillAddAmount: Int = 1
    @FocusState private var qtyFocused: Bool
    @State private var refillMode: DateMode = .none
    @State private var refillExpirationDate = Date()
    @State private var refillPurchaseDate = Date()
       
    
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
                            refillAddAmount = 1
                            refillMode = item.dateMode
                            refillExpirationDate = item.expirationDate ?? Date()
                            refillPurchaseDate = item.purchaseDate ?? Date()
                        } label: {
                            Label("Refill", systemImage: "arrow.clockwise")
                        }
                        
                        .tint(.blue)
                        
                        Button {
                            viewModel.setFavorite(item)
                            favoriteName = item.name
                            showingFavoriteAlert = true
                        } label: {
                            Label("Favorite", systemImage: "star.fill")
                        }
                        .tint(.yellow)
                    }
                    
                    
                    
                }
                .onDelete(perform: viewModel.deleteItem)
            }
            .navigationTitle("My Pantry")
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
                NavigationView {
                    Form {
                        Section(header: Text("Quantity")) {
                            //                            Stepper(value: $refillAddAmount, in: 1...999) {
                            //                                Text("Add \(refillAddAmount)")
                            //                            }
                            TextField("Add", value: $refillAddAmount, format: .number)
                                .keyboardType(.numberPad)
                                .focused($qtyFocused)
                                .onChange(of: refillAddAmount) { refillAddAmount = min(1000, max(1, refillAddAmount)) }
                            
                                .toolbar {               // keyboard Done button
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button("Done") { qtyFocused = false }
                                    }
                                }
                        }
                        
                        Section(header: Text("Date tracking")) {
                            Picker("Track with", selection: $refillMode) {
                                Text("Expiration").tag(DateMode.expiration)
                                Text("Purchase").tag(DateMode.purchase)
                                Text("None").tag(DateMode.none)
                            }
                            .pickerStyle(.segmented)
                            
                            switch refillMode {
                            case .expiration:
                                DatePicker("Expiration Date",
                                           selection: $refillExpirationDate,
                                           displayedComponents: .date)
                            case .purchase:
                                DatePicker("Purchase Date",
                                           selection: $refillPurchaseDate,
                                           displayedComponents: .date)
                            case .none:
                                EmptyView()
                            }
                        }
                    }
                    .navigationTitle("Refill \(target.name)")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { refillTarget = nil }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                viewModel.refillItem(
                                    target,
                                    add: refillAddAmount,
                                    dateMode: refillMode,
                                    expirationDate: refillMode == .expiration ? refillExpirationDate : nil,
                                    purchaseDate: refillMode == .purchase ? refillPurchaseDate : nil
                                )
                                refillTarget = nil
                            }
                        }
                    }
                }
            }
            
            .alert("Favorite set", isPresented: $showingFavoriteAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("\(favoriteName) will show in the small widget")
            }
            
        }
    }
}
