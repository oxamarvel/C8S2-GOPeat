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

extension PriceRangeFilter: Codable {
    enum CodingKeys: String, CodingKey {
        case below15K, fifteenTo40K, fortyTo100K, over100K
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        below15K = try container.decode(Bool.self, forKey: .below15K)
        fifteenTo40K = try container.decode(Bool.self, forKey: .fifteenTo40K)
        fortyTo100K = try container.decode(Bool.self, forKey: .fortyTo100K)
        over100K = try container.decode(Bool.self, forKey: .over100K)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(below15K, forKey: .below15K)
        try container.encode(fifteenTo40K, forKey: .fifteenTo40K)
        try container.encode(fortyTo100K, forKey: .fortyTo100K)
        try container.encode(over100K, forKey: .over100K)
    }
}


struct NewFilter: View {
    @State var showAllFilter: Bool = false
    let categories: [String]
    @Binding var selectedCategories: [String]
    @Binding var isOpenNow: Bool?
    @Binding var priceFilter: PriceRangeFilter
    
    // Computed property to check if any filters are active
    private var hasActiveFilters: Bool {
        isOpenNow == true ||
        !selectedCategories.isEmpty ||
        priceFilter.isActive
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Clear all button (only shown when filters are active)
            if hasActiveFilters {
                Button(action: clearAllFilters) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .foregroundColor(Color(.systemGray))
                }
                .transition(.scale)
            }
            
            // Selected filters pill view
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if isOpenNow == true {
                        FilterPill(text: "Open Now") {
                            isOpenNow = false
                        }
                    }
                    
                    ForEach(selectedCategories, id: \.self) { category in
                        FilterPill(text: category) {
                            selectedCategories.removeAll { $0 == category }
                        }
                    }
                    
                    if priceFilter.below15K {
                        FilterPill(text: "Below Rp15K") {
                            priceFilter.below15K = false
                        }
                    }
                    if priceFilter.fifteenTo40K {
                        FilterPill(text: "Rp15K-Rp40K") {
                            priceFilter.fifteenTo40K = false
                        }
                    }
                    if priceFilter.fortyTo100K {
                        FilterPill(text: "Rp40K-Rp100K") {
                            priceFilter.fortyTo100K = false
                        }
                    }
                    if priceFilter.over100K {
                        FilterPill(text: "Over Rp100K") {
                            priceFilter.over100K = false
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(maxWidth: .infinity)
            
            // Filter button
            Button {
                showAllFilter = true
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
                    .foregroundStyle(Color("Default"))
            }
        }
        .animation(.default, value: hasActiveFilters)
        .sheet(isPresented: $showAllFilter) {
            ModalFilter(
                categories: categories,
                selectedCategories: $selectedCategories,
                isOpenNow: Binding(get: { isOpenNow ?? false }, set: { isOpenNow = $0 }),
                priceFilter: $priceFilter
            )
        }
    }
    
    private func clearAllFilters() {
        withAnimation {
            isOpenNow = false
            selectedCategories = []
            priceFilter = PriceRangeFilter()
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
    @State private var tempIsHalal: Bool = false
    @State private var useSavedFilters = false
    @State private var tempPriceFilter = PriceRangeFilter()
    @State private var savedFilters: SavedFilterPreferences? = nil
    
    private let savedFiltersKey = "savedFilterPreferences"
        
    private var selectedFilterCount: Int {
        var count = 0
        if tempIsOpenNow { count += 1 }
        if tempIsHalal { count += 1 }
        count += selectedCategories.count
        if tempPriceFilter.below15K { count += 1 }
        if tempPriceFilter.fifteenTo40K { count += 1 }
        if tempPriceFilter.fortyTo100K { count += 1 }
        if tempPriceFilter.over100K { count += 1 }
        return count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            HStack {
                Text("Filters")
                    .font(.title3.bold())
                
                Spacer()
                
                Button(action: onClear) {
                    Text("Clear")
                        .font(.title3.bold())
                }
                .foregroundStyle(Colors.gopGreenDark)
            }
            .padding(.horizontal)
                        
            ScrollView() {
                VStack(alignment: .leading, spacing: 20) {
                    // Use Saved Filters section - Always visible
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle("Use Saved Filters", isOn: $useSavedFilters)
                            .toggleStyle(CheckboxStyle())
                            .font(.headline.bold())
                            .onChange(of: useSavedFilters) { oldValue, newValue in
                                withAnimation {
                                    if newValue {
                                        loadSavedFilters()
                                    } else {
                                        clearTemporaryFilters()
                                    }
                                }
                            }
                        
                        // Saved filters preview
                        if savedFilters != nil {
                            VStack(alignment: .leading, spacing: 8) {
                                if savedFilters!.isOpenNow {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Colors.gopGreenDark)
                                        Text("Open Now")
                                            .font(.subheadline)
                                    }
                                    .transition(.opacity.combined(with: .slide))
                                }
                                
                                if savedFilters!.isHalal {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Colors.gopGreenDark)
                                        Text("Halal")
                                            .font(.subheadline)
                                    }
                                    .transition(.opacity.combined(with: .slide))
                                }
                                                    
                                if savedFilters!.priceFilter.below15K {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Colors.gopGreenDark)
                                        Text("Below Rp15.000")
                                            .font(.subheadline)
                                    }
                                    .transition(.opacity.combined(with: .slide))
                                }
                                if savedFilters!.priceFilter.fifteenTo40K {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Colors.gopGreenDark)
                                        Text("Rp15.000-Rp40.000")
                                            .font(.subheadline)
                                    }
                                    .transition(.opacity.combined(with: .slide))
                                }
                                if savedFilters!.priceFilter.fortyTo100K {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Colors.gopGreenDark)
                                        Text("Rp40.000-Rp100.000")
                                            .font(.subheadline)
                                    }
                                    .transition(.opacity.combined(with: .slide))
                                }
                                if savedFilters!.priceFilter.over100K {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Colors.gopGreenDark)
                                        Text("Over Rp100.000")
                                            .font(.subheadline)
                                    }
                                    .transition(.opacity.combined(with: .slide))
                                }
                                                    
                                if !savedFilters!.selectedCategories.isEmpty {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Cuisine Types:")
                                            .font(.subheadline.bold())
                                            .padding(.top, 4)
                                        
                                        WrappingHStack(spacing: 6, lineSpacing: 6) {
                                            ForEach(savedFilters!.selectedCategories, id: \.self) { category in
                                                Text(category)
                                                    .font(.caption)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Colors.gopGreenLight)
                                                    .cornerRadius(12)
                                            }
                                        }
                                    }
                                    .transition(.opacity.combined(with: .slide))
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
//                            .animation(.default, value: savedFilters)
                        } else {
                            // Empty state when no saved filters
                            Text("No saved filters available")
                                .font(.subheadline)
                                .foregroundColor(.gray)
//                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider().padding(.horizontal)
                    
                    // Tenant Status Filter
                    VStack(alignment: .leading) {
                        Text("Tenant")
                            .font(.headline.bold())
                        
                        HStack(spacing: 8) {
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
                            
                            Button {
                                tempIsHalal.toggle()
                            } label: {
                                Text("Halal")
                                    .font(.caption)
                            }
                            .font(.body)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(tempIsHalal ? Colors.gopGreenLight : Colors.gopWhite)
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
                            .font(.headline.bold())
                        
                        Toggle("Below Rp15.000", isOn: $tempPriceFilter.below15K)
                            .toggleStyle(CheckboxStyle())
                            .font(.body)
                        
                        Toggle("Rp15.000 - Rp40.000", isOn: $tempPriceFilter.fifteenTo40K)
                            .toggleStyle(CheckboxStyle())
                            .font(.body)
                        
                        Toggle("Rp40.000 - Rp100.000", isOn: $tempPriceFilter.fortyTo100K)
                            .toggleStyle(CheckboxStyle())
                            .font(.body)
                        
                        Toggle("Over Rp100.000", isOn: $tempPriceFilter.over100K)
                            .toggleStyle(CheckboxStyle())
                            .font(.body)
                    }
                    .padding(.horizontal)
                    
                    Divider().padding(.horizontal)
                    
                    // Cuisine Type Filter (without Halal/Non-Halal)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Cuisine Type")
                            .font(.headline.bold())
                        
                        WrappingHStack(spacing: 8, lineSpacing: 10) {
                            // Filter out "Halal" and "Non-Halal" from categories
                            ForEach(categories.filter { $0 != "Halal" && $0 != "Non-Halal" }, id: \.self) { category in
                                Button {
                                    if !selectedCategories.contains(category) {
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
                .font(.headline.bold())
                .foregroundStyle(.black)
                .padding()
                .background(Colors.gopGrayLight)
                .cornerRadius(13)
                            
                Button(action: onApply) {
                    HStack {
                        if selectedFilterCount > 0 {
                            Text("Apply (\(selectedFilterCount)) Filters")
                                
                        }
                        else {
                            Text("Apply (0) Filters")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .font(.headline.bold())
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
            tempIsOpenNow = isOpenNow
            tempIsHalal = selectedCategories.contains("Halal")
            tempPriceFilter = priceFilter
            selectedCategories.removeAll { $0 == "Halal" }
            loadInitialSavedFilters()
        }
    }
    
    private func loadInitialSavedFilters() {
        if let data = UserDefaults.standard.data(forKey: savedFiltersKey) {
            savedFilters = try? JSONDecoder().decode(SavedFilterPreferences.self, from: data)
            useSavedFilters = savedFilters != nil
        }
    }
    
    private func loadSavedFilters() {
        if let data = UserDefaults.standard.data(forKey: savedFiltersKey),
           let decoded = try? JSONDecoder().decode(SavedFilterPreferences.self, from: data) {
            withAnimation {
                savedFilters = decoded
                selectedCategories = decoded.selectedCategories
                tempIsOpenNow = decoded.isOpenNow
                tempIsHalal = decoded.isHalal
                tempPriceFilter = decoded.priceFilter
            }
        }
    }
    
    private func saveCurrentFilters() {
        let preferences = SavedFilterPreferences(
            selectedCategories: selectedCategories,
            isOpenNow: tempIsOpenNow,
            isHalal: tempIsHalal,
            priceFilter: tempPriceFilter
        )
            
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: savedFiltersKey)
            withAnimation {
                savedFilters = preferences
                useSavedFilters = true
            }
        }
    }
    
    private func clearSavedFilters() {
        UserDefaults.standard.removeObject(forKey: savedFiltersKey)
        withAnimation {
            savedFilters = nil
            useSavedFilters = false
        }
    }
        
    private func clearTemporaryFilters() {
        withAnimation {
            selectedCategories = []
            tempIsOpenNow = false
            tempIsHalal = false
            tempPriceFilter = PriceRangeFilter()
        }
    }
    
    private func onApply() {
        isOpenNow = tempIsOpenNow
        priceFilter = tempPriceFilter
        dismiss()
    }
        
    private func onSave() {
        saveCurrentFilters()
        useSavedFilters = true
    }
        
    private func onClear() {
        if useSavedFilters {
            clearSavedFilters()
        }
        useSavedFilters = false
        tempIsOpenNow = false
        selectedCategories = []
        tempPriceFilter = PriceRangeFilter()
    }
    
//    private func conflictingCategory(for category: String) -> String? {
//        if category.hasPrefix("Non-") {
//            let conflictCategory = String(category.dropFirst(4))
//            return selectedCategories.contains(conflictCategory) ? conflictCategory : nil
//        } else {
//            let conflictCategory = "Non-" + category
//            return selectedCategories.contains(conflictCategory) ? conflictCategory : nil
//        }
//    }
}


struct FilterPill: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Colors.gopGreenLight)
        .foregroundColor(.black)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Colors.gopGreenDark, lineWidth: 1)
        )
    }
}




struct SavedFilterPreferences: Codable {
    var selectedCategories: [String]
    var isOpenNow: Bool
    var isHalal: Bool
    var priceFilter: PriceRangeFilter
}
