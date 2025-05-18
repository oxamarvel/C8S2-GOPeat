//
//  NewFilter.swift
//  GOPeat
//
//  Created by Oxa Marvel on 17/05/25.
//
//  WIP


import SwiftUI

// Price range filter state to be used in parent view
struct PriceRangeFilter: Equatable {
    var below15K: Bool = false
    var fifteenTo40K: Bool = false
    var fortyTo100K: Bool = false
    var over100K: Bool = false
    
    var isActive: Bool {
        below15K || fifteenTo40K || fortyTo100K || over100K
    }
    
    // Helper function to extract lower price from range string
    private func extractLowerPrice(_ priceRange: String) -> Int? {
        // Remove any dots (thousand separators) and whitespace
        let cleanedString = priceRange
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: " ", with: "")
        
        let components = cleanedString.components(separatedBy: "-")
        guard components.count == 2 else { return nil }
        
        // Try to parse both parts as integers
        if let lower = Int(components[0]), Int(components[1]) != nil {
            return lower // Return the lower value
        }
        return nil
    }
    
    func matches(_ priceRange: String) -> Bool {
        guard isActive else { return true } // Show all if no filters selected
        
        guard let lowerPrice = extractLowerPrice(priceRange) else {
            return false // If we can't parse the price range, exclude it
        }
        
        // Check against all active price filters using LOWER price
        if below15K && lowerPrice <= 14999 { return true }
        if fifteenTo40K && lowerPrice >= 15000 && lowerPrice <= 39999 { return true }
        if fortyTo100K && lowerPrice >= 40000 && lowerPrice <= 100000 { return true }
        if over100K && lowerPrice > 100000 { return true }
        
        return false
    }
}

struct NewFilter: View {
    @State var showAllFilter: Bool = false
    let categories: [String]
    @Binding var selectedCategories: [String]
    @Binding var isOpenNow: Bool?
    @Binding var priceFilter: PriceRangeFilter
    
    var body: some View {
        Button {
            showAllFilter = true
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 20)
                .foregroundStyle(Color("Default"))
        }
        .sheet(isPresented: $showAllFilter) {
            ModalFilter(
                categories: categories,
                selectedCategories: $selectedCategories,
                isOpenNow: Binding(get: { isOpenNow ?? false }, set: { isOpenNow = $0 }),
                priceFilter: $priceFilter
            )
        }
    }
}

struct ModalFilter: View {
    @Environment(\.dismiss) private var dismiss
    
    let categories: [String]
    @Binding var selectedCategories: [String]
    @Binding var isOpenNow: Bool
    @Binding var priceFilter: PriceRangeFilter
    
    @State private var tempIsOpenNow: Bool = false
    @State private var useSavedFilters = false
    @State private var tempPriceFilter = PriceRangeFilter()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            HStack {
                Text("Filters")
                    .font(.title2.bold())
                
                Spacer()
                
                Button(action: onClear) {
                    Text("Clear")
                        .font(.title2.bold())
                }
                .foregroundStyle(Colors.gopGreenDark)
            }
            .padding(.horizontal)
                        
            ScrollView() {
                VStack(alignment: .leading, spacing: 20) {
                    Toggle("Use Saved Filters", isOn: $useSavedFilters)
                        .toggleStyle(CheckboxStyle())
                        .font(.title3.bold())
                        .padding(.horizontal)
                    
                    Divider().padding(.horizontal)
                    
                    // Tenant Status Filter
                    VStack(alignment: .leading) {
                        Text("Tenant")
                            .font(.title3.bold())
                        
                        HStack {
                            Button {
                                tempIsOpenNow.toggle()
                            } label: {
                                Text("Open Now")
                                    .font(.caption)
                            }
                            .font(.body)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(tempIsOpenNow ? Colors.gopGreenLight : Colors.gopWhite)
                            .foregroundColor(.black)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Colors.gopGreenDark, lineWidth: 1.5)
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider().padding(.horizontal)
                    
                    // Price Filter Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Price")
                            .font(.title3.bold())
                        
                        Toggle("Below Rp15.000", isOn: $tempPriceFilter.below15K)
                            .toggleStyle(CheckboxStyle())
                            .font(.title3)
                        
                        Toggle("Rp15.000 - Rp40.000", isOn: $tempPriceFilter.fifteenTo40K)
                            .toggleStyle(CheckboxStyle())
                            .font(.title3)
                        
                        Toggle("Rp40.000 - Rp100.000", isOn: $tempPriceFilter.fortyTo100K)
                            .toggleStyle(CheckboxStyle())
                            .font(.title3)
                        
                        Toggle("Over Rp100.000", isOn: $tempPriceFilter.over100K)
                            .toggleStyle(CheckboxStyle())
                            .font(.title3)
                    }
                    .padding(.horizontal)
                    
                    Divider().padding(.horizontal)
                    
                    // Cuisine Type Filter
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Cuisine Type")
                            .font(.title3.bold())
                        
                        WrappingHStack(spacing: 8, lineSpacing: 10) {
                            ForEach(categories.sorted { lhs, rhs in
                                let lhsSelected = selectedCategories.contains(lhs)
                                let rhsSelected = selectedCategories.contains(rhs)
                                return lhsSelected && !rhsSelected
                            }, id: \.self) { category in
                                Button {
                                    if !selectedCategories.contains(category) {
                                        if let conflictCategory = conflictingCategory(for: category) {
                                            selectedCategories.removeAll { $0 == conflictCategory }
                                        }
                                        selectedCategories.append(category)
                                    } else {
                                        selectedCategories.removeAll { $0 == category }
                                    }
                                } label: {
                                    Text(category)
                                        .font(.caption)
                                }
                                .font(.body)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(selectedCategories.contains(category) ? Colors.gopGreenLight : Colors.gopWhite)
                                .foregroundColor(.black)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Colors.gopGreenDark, lineWidth: 1.5)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Action Buttons
            HStack {
                Button(action: onSave) {
                    Text("Save Filters")
                        .frame(maxWidth: .infinity)
                }
                .font(.title2.bold())
                .foregroundStyle(.black)
                .padding()
                .background(Colors.gopGrayLight)
                .cornerRadius(13)
                
                Button(action: onApply) {
                    Text("Apply")
                        .frame(maxWidth: .infinity)
                }
                .font(.title2.bold())
                .foregroundStyle(.black)
                .padding()
                .background(Colors.gopGold)
                .cornerRadius(13)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
        .padding(.top)
        .presentationDragIndicator(.visible)
        .onAppear {
            // Initialize temp values when view appears
            tempIsOpenNow = isOpenNow
            tempPriceFilter = priceFilter
        }
    }
    
    private func onApply() {
        isOpenNow = tempIsOpenNow
        priceFilter = tempPriceFilter
        dismiss()
    }
    
    private func onSave() {
        // Save filter logic here if needed
    }
    
    private func onClear() {
        useSavedFilters = false
        tempIsOpenNow = false
        selectedCategories = []
        tempPriceFilter = PriceRangeFilter()
    }
    
    
    private func conflictingCategory(for category: String) -> String? {
        if category.hasPrefix("Non-") {
            let conflictCategory = String(category.dropFirst(4))
            return selectedCategories.contains(conflictCategory) ? conflictCategory : nil
        } else {
            let conflictCategory = "Non-" + category
            return selectedCategories.contains(conflictCategory) ? conflictCategory : nil
        }
    }
}
