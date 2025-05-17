//
//  NewFilter.swift
//  GOPeat
//
//  Created by Oxa Marvel on 17/05/25.
//

import SwiftUI


struct NewFilter: View {
//    let categories: [String]

    @State var showAllFilter: Bool = false
    @State var isAdditionalFilterUsed: Bool = false

    
    var body: some View {
        
        
        Button {
            showAllFilter = true
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 20)
                .foregroundStyle(Color("Default"))
                .opacity(isAdditionalFilterUsed ? 1 : 0.3)
        }
        .sheet(isPresented: $showAllFilter) {
            ModalFilter()
            
            
//            MoreFilterView(
//                maxPrice: Binding(get: { maxPrice ?? 100000 }, set: { maxPrice = $0 }),
//                isOpenNow: Binding(get: { isOpenNow ?? false }, set: { isOpenNow = $0 })
//            )
        }
        
    }
}



struct ModalFilter: View {
//    let categories: [String]

    @State private var selectedTenant: Set<String> = []
    
//    @State private var selectedPriceRanges: Set<PriceRange> = []

    @State private var selectedCategories: Set<FoodCategory> = []
    
    @Environment(\.dismiss) var dismiss
    @State private var useSavedFilters = false
    @State private var priceBelow15K = false
    @State private var price15to40K = false
    @State private var price40to100K = false
    @State private var priceAbove100K = false
    
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 30) {
            
            HStack {
                Text("Filters")
                    .font(.title2.bold())
                
                Spacer()
                
                Button(action: {
                    useSavedFilters = false
                    selectedTenant.removeAll()
//                    selectedPriceRanges.removeAll()
                    selectedCategories.removeAll()
                }) {
                    Text("Clear")
                        .font(.title2.bold())
                }
                .foregroundStyle(Colors.gopGreenDark)

            }
            .padding(.horizontal)
                        
            // Filter Options
            ScrollView() {
                VStack(alignment: .leading, spacing: 20) {
                    Toggle("Use Saved Filters", isOn: $useSavedFilters)
                        .toggleStyle(CheckboxStyle())
                        .font(.title3.bold())
                        .padding(.horizontal)
                    
                    Divider().padding(.horizontal)
                    
                    VStack {
                        Text("Tenant")
                            .font(.title3.bold())
                        
                    }
                    .padding(.horizontal)
                    
                    Divider().padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Price")
                            .font(.title3.bold())
                        
//                        ForEach(PriceRange.allCases) { range in
//                            Toggle(range.rawValue, isOn: Binding(
//                                get: { selectedPriceRanges.contains(range) },
//                                set: { isSelected in
//                                    if isSelected {
//                                        selectedPriceRanges.insert(range)
//                                    } else {
//                                        selectedPriceRanges.remove(range)
//                                    }
//                                }
//                            ))
//                            .toggleStyle(CheckboxStyle())
//                            .font(.title3)
//                        }
                    }
                    .padding(.horizontal)
                    
                    Divider().padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Cuisine Type")
                            .font(.title3.bold())

//                        FlowLayout(data: categories.sorted(by: { $0.rawValue < $1.rawValue }), spacing: 7) { category in
//                            Button(action: {
//                                if selectedCategories.contains(category) {
//                                    selectedCategories.remove(category)
//                                } else {
//                                    selectedCategories.insert(category)
//                                }
//                            }) {
//                                Text(category.rawValue)
//                                    .font(.body)
//                                    .padding(.vertical, 8)
//                                    .padding(.horizontal, 16)
//                                    .background(selectedCategories.contains(category) ? Colors.gopGreenLight : Colors.gopWhite)
//                                    .foregroundColor(.black)
//                                    .cornerRadius(20)
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 20)
//                                            .stroke(Colors.gopGreenDark, lineWidth: 1.5)
//                                    )
//                            }
//                        }

                    }
                    .padding(.horizontal)
                }
            }
            // Filter Options
            
            HStack {
                Button(action: {
                }){
                    Text("Save Filters")
                        .frame(maxWidth: .infinity)
                }
                .font(.title2.bold())
                .foregroundStyle(.black)
                .padding()
                .background(Colors.gopGrayLight)
                .cornerRadius(13)
                
                Button(action: {
                }){
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
    }
}
