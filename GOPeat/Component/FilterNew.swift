//
//  NewFilter.swift
//  GOPeat
//
//  Created by Oxa Marvel on 17/05/25.
//
//  WIP


import SwiftUI


struct NewFilter: View {
    @State var showAllFilter: Bool = false

    let categories: [String]
    @Binding var selectedCategories: [String]
    @Binding var isOpenNow: Bool?
    
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
                isOpenNow: Binding(get: { isOpenNow ?? false }, set: { isOpenNow = $0 })
            )
        }
    }
}



struct ModalFilter: View {
    @Environment(\.dismiss) private var dismiss
    
    let categories: [String]
    @Binding var selectedCategories: [String]
    @Binding var isOpenNow: Bool


    @State private var selectedTenant: Set<String> = []
    
    
    @State var tempIsOpenNow: Bool = false
    
    @State private var useSavedFilters = false
    @State private var priceBelow15K = false
    @State private var price15to40K = false
    @State private var price40to100K = false
    @State private var priceOver100K = false
    
    
    private func onApply(){
        isOpenNow = tempIsOpenNow
        dismiss()
    }
    
    private func onSave(){
        
    }
    
    private func onClear(){
        useSavedFilters = false
        
        isOpenNow = false
        tempIsOpenNow = false
        
        priceBelow15K = false
        price15to40K = false
        price40to100K = false
        priceOver100K = false
        
        selectedCategories = []
    }
    
    private func conflictingCategory(for category: String) -> String? {
        if category.hasPrefix("Non-") {
            // If start with "Non-", check category without "Non-"
            let conflictCategory = String(category.dropFirst(4))
            return selectedCategories.contains(conflictCategory) ? conflictCategory : nil
        } else {
            // If start without "Non-", check category with "Non-"
            let conflictCategory = "Non-" + category
            return selectedCategories.contains(conflictCategory) ? conflictCategory : nil
        }
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 30) {
            
            HStack {
                Text("Filters")
                    .font(.title2.bold())
                
                Spacer()
                
                Button(action: {
                    onClear()
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
                    
                    VStack(alignment: .leading) {
                        Text("Tenant")
                            .font(.title3.bold())
                        
                        HStack{
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
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Price")
                            .font(.title3.bold())
                        
                        Toggle("Below Rp15.000", isOn: $priceBelow15K)
                            .toggleStyle(CheckboxStyle())
                            .font(.title3)
                        Toggle("Rp15.000 - Rp40.000", isOn: $price15to40K)
                            .toggleStyle(CheckboxStyle())
                            .font(.title3)
                        Toggle("Rp40.000 - Rp100.000", isOn: $price40to100K)
                            .toggleStyle(CheckboxStyle())
                            .font(.title3)
                        Toggle("Over Rp100.000", isOn: $priceOver100K)
                            .toggleStyle(CheckboxStyle())
                            .font(.title3)
                    }
                    .padding(.horizontal)
                    
                    Divider().padding(.horizontal)
                    
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
            // Filter Options
            
            HStack {
                Button(action: {
                    onSave()
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
                    onApply()
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
        .padding(.top)
        .presentationDragIndicator(.visible)
    }
}
