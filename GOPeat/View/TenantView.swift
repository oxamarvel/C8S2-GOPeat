//
//  CanteenCard.swift
//  GOPeat
//
//  Created by Oxa Marvel on 24/03/25.
//


import SwiftUI

let sampleImages = ["image1", "image2", "image3", "image4", "image5"]

class FoodFilterViewModel: ObservableObject{
    @Published var selectedCategories: [String] = []
    @Published var filteredFoods: [Food] = []
    
    let foods: [Food]
    let categories: [String] = FoodCategory.allCases.map{ $0.rawValue }
    
    init(foods: [Food]) {
        let tenant = foods.first?.tenant
        var tempfoods = foods
        let dumy = Food(name: "Dumy", description: "Dumy", categories: [.nonSpicy, .nonGreasy, .nonSweet, .spicy, .greasy, .sweet, .soup, .roast, .savory], tenant: tenant)
        tempfoods.insert(dumy, at: 0)
        self.foods = tempfoods
        self.filteredFoods = tempfoods
    }
    
    func updateFilteredFood(selectedCategories: [String]) {
        if selectedCategories.isEmpty {
            filteredFoods = foods
        } else {
            filteredFoods = foods.filter { food in
                Set(selectedCategories).isSubset(of: Set(food.categories.map { $0.rawValue }))
            }
        }
    }
}


// Tenant Page
struct TenantView: View {
    @Environment(\.dismiss) var dismiss
    let foods: [Food]
    let tenant: Tenant
    let isHalal: Bool
    let preorderInformation: Bool
    let symbol: String
    let color: Color
    @Binding var selectedCategories: [String]
    @StateObject private var viewModel: FoodFilterViewModel
    
    @State var priceFilter = PriceRangeFilter()
    @State private var maxPrice: Double? = nil
    @State private var isOpenNow: Bool? = nil

    
    init(tenant: Tenant, foods: [Food], selectedCategories: Binding<[String]>) {
        self.foods = foods
        self.tenant = tenant
        self.isHalal = tenant.isHalal ?? false
        self.preorderInformation = tenant.preorderInformation ?? false
        self.symbol = preorderInformation ? "checkmark.circle.fill" : "xmark.circle.fill"
        self.color = preorderInformation ? .green : .red
        self._selectedCategories = selectedCategories
        _viewModel = StateObject(wrappedValue: FoodFilterViewModel(foods: foods))
        
        let appear = UINavigationBarAppearance()
        
        appear.shadowColor = .clear
        appear.shadowImage = UIImage()
        
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().standardAppearance = appear
        UINavigationBar.appearance().compactAppearance = appear
        UINavigationBar.appearance().scrollEdgeAppearance = appear
        
        UITabBar.appearance().isHidden = true
    }
    private func tenantHeader() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack (alignment: .leading) {
                Text(tenant.name)
                    .font(.largeTitle.bold())
                Text(tenant.canteen?.name ?? "")
                    .font(.body.bold())
                    .foregroundColor(.gray)
                Spacer()
            }

            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 10) {
                    Label(tenant.operationalHours, systemImage: "clock")
                    
                    Label("Rp\(tenant.priceRange)", systemImage: "banknote")
                    
                    HStack() {
                        Label(tenant.contactPerson, systemImage: "phone")
                        Text("(Pre-order")
                        (Text(Image(systemName: symbol)).foregroundColor(color) + Text(")"))
                            .font(.body)
                    }
                }
                
                Spacer()
                
                if tenant.isHalal == true {
                    Image("halal")
                        .resizable()
                        .frame(width: 40, height: 40)
                } else {
                    /*@START_MENU_TOKEN@*/EmptyView()/*@END_MENU_TOKEN@*/
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func imageSlider(image: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(image, id: \.self) { imageName in
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 150, height: 200)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                        )
                }
            }
            .padding(.horizontal)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack (alignment: .top){
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Tenant Header
                        tenantHeader()
                        
                        // Tenant's Side-scrolling images
                        imageSlider(image: sampleImages)
                        
                        
                        
                        NewFilter(
                            categories          : viewModel.categories,
                            selectedCategories  : $selectedCategories,
                            isOpenNow           : $isOpenNow,
                            priceFilter         : $priceFilter
                        )
                            .onChange(of: selectedCategories) { _, _ in
                                viewModel.updateFilteredFood(selectedCategories: selectedCategories)
                            }
                            .padding(.horizontal)
                        
                        // Filter Component
                        Filter(
                            categories          : viewModel.categories,
                            selectedCategories  : $selectedCategories,
                            maxPrice            : $maxPrice,
                            isOpenNow           : $isOpenNow)
                            .onChange(of: selectedCategories) { _, _ in
                                viewModel.updateFilteredFood(selectedCategories: selectedCategories)
                            }.padding(.horizontal, 20)
                        
                        // List of Food
                        VStack(alignment: .leading, spacing: 10) {
                            Divider()
                            Text("Foods")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.bottom, 5)
                            if viewModel.filteredFoods.count == 1 && viewModel.filteredFoods.first?.name == "Dumy" {
                                Text("Not Found")
                                    .font(.subheadline)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                            } else {
                                ForEach(viewModel.filteredFoods.filter { $0.name != "Dumy" }) { food in
                                    FoodCard(food: food)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .scrollIndicators(.hidden)
            }
            .onAppear(){
                selectedCategories = selectedCategories.filter {$0 != "Halal" &&  $0 != "Non-Halal"}
                viewModel.updateFilteredFood(selectedCategories: selectedCategories)
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        (Text(Image(systemName: "chevron.left"))
                         + Text(" Back"))
                        .foregroundStyle(Colors.gopGreenDark)
                    }
                }
            }
        }
    }
}

// Food Card
struct FoodCard: View {
    let food: Food
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(food.name)
                    .font(.headline)
                    
                Text(food.desc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                WrappingHStack(spacing: 5) {
                    ForEach(food.categories, id: \.self) { category in
                        Text(category.rawValue)
                            .padding(5)
                            .font(.caption)
                            .foregroundColor(.primary)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Color.gray.opacity(0.0), lineWidth: 1)
                                )
                    }
                }
                .padding(.top, 10)

                
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 5) {
//                        ForEach(food.categories, id: \.self) { category in
//                            Text(category.rawValue)
//                                .padding(5)
//                                .font(.caption)
//                                .foregroundColor(.primary)
//                                .background(Color.gray.opacity(0.1))
//                                .cornerRadius(3)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 3)
//                                        .stroke(Color.gray.opacity(0.0), lineWidth: 1)
//                                    )
//                        }
//                    }
//                }
//                .padding(.top, 10)
            }
                
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.07))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.0), lineWidth: 1)
        )
    }
}
