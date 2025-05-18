import SwiftUI
import SwiftData
import MapKit

class TenantSearchViewModel: ObservableObject{
    @Published var searchTerm: String = ""
    @Published var sheeHeight: PresentationDetent = .fraction(0.1)
    @Published var selectedCategories: [String] = []
    @Published var filteredTenants: [Tenant] = []
    @Published var recentSearch: [String] = []
    @Published var maxPrice: Double? = 100000
    @Published var priceFilter = PriceRangeFilter()
    @Published var isOpenNow: Bool? = false
    
    let tenants: [Tenant]
    let categories: [String] = ["Halal", "Non-Halal"] + FoodCategory.allCases.map{ $0.rawValue }
    
    init(tenants: [Tenant]) {
        self.tenants = tenants
        self.filteredTenants = tenants
    }
    func doSearch(searchTerm: String) -> [Tenant] {
        guard !searchTerm.isEmpty else { return filteredTenants }
        let loweredCaseString = searchTerm.lowercased()
        let foodCategories = selectedCategories.filter{$0 != "Halal" && $0 != "Non-Halal"}
        return filteredTenants.filter { tenant in
            //Search by tenant name
            tenant.name.lowercased().contains(loweredCaseString) ||
            //Search by food name while considering filters
            tenant.foods.filter{food in
                Set(foodCategories).isSubset(of: Set(food.categories.map {$0.rawValue}))
            }.contains { food in
                food.name.lowercased().contains(loweredCaseString)
            }
        }
    }
    func isCurrentlyOpen(_ hours: String) -> Bool {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let now = timeFormatter.string(from: Date())
        let hoursRange = hours.split(separator: "-")
        guard hoursRange.count == 2 else { return false }
        let start = String(hoursRange[0])
        let end = String(hoursRange[1])
        return now >= start && now <= end
    }
    
    func updateFilteredTenant() {
        //Filter Tenant by Halal / Non-Halal
        let containsHalal = selectedCategories.contains("Halal")
        let containsNonHalal = selectedCategories.contains("Non-Halal")
        
        var halalTenants = tenants
        
        if containsHalal {
            halalTenants = halalTenants.filter { $0.isHalal == true }
        }
        if containsNonHalal {
            halalTenants = halalTenants.filter { $0.isHalal == false }
        }
        
        let foodCategories = selectedCategories.filter { $0 != "Halal" && $0 != "Non-Halal" }
        
        filteredTenants = halalTenants.filter { tenant in
            // Price range filtering
            let priceMatch = priceFilter.matches(tenant.priceRange)
            
            // Existing filters
            let withinPriceRange = tenant.priceRange.split(separator: "-").compactMap {
                Double($0.replacingOccurrences(of: ".", with: ""))
            }
            let minPriceInRange = withinPriceRange.min() ?? 0
            let isPriceValid = minPriceInRange <= maxPrice ?? 100000
            let isOpen = !(isOpenNow ?? false) || isCurrentlyOpen(tenant.operationalHours)
            
            return priceMatch && isPriceValid && isOpen && (foodCategories.isEmpty || tenant.foods.contains { food in
                Set(foodCategories).isSubset(of: Set(food.categories.map { $0.rawValue }))
            })
        }
        
        
    }
    
    func saveRecentSearch(searchTerm: String) {
        recentSearch.removeAll { $0.lowercased() == searchTerm.lowercased() }
        recentSearch.insert(searchTerm, at: 0)
        if recentSearch.count > 5 {
            recentSearch = Array(recentSearch.prefix(5))
        }
    }
    func onClose() {
        sheeHeight = .fraction(0.1)
        searchTerm = ""
        selectedCategories = []
        filteredTenants = tenants
        isOpenNow = false
        maxPrice = 100000
        priceFilter = PriceRangeFilter() // Reset price filter
    }
}









struct ModalSearch: View {
    @FocusState var isTextFieldFocused: Bool
    private let maxHeight: PresentationDetent = .fraction(0.95)
    @ObservedObject var tenantSearchViewModel: TenantSearchViewModel
    
    private func showTenant(tenants: [Tenant]) -> some View {
        VStack(alignment: .leading) {
            Text("Tenants")
                .font(.headline)
                .fontWeight(.bold)
                .padding(0)
            Divider()
            if !tenants.isEmpty {
                ForEach(tenants) {tenant in
                    TenantCard(tenant: tenant, selectedCategories: $tenantSearchViewModel.selectedCategories)
                }
            } else {
                Text("Not Found")
                    .font(.subheadline)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)
            }
        }
    }

    private func showRecentSearch() -> some View {
        VStack(alignment: .leading) {
            Text("Your Search History")
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(0)
            Divider()
            HStack{
                ForEach(tenantSearchViewModel.recentSearch, id: \.self) { recent in
                    Button {
                        tenantSearchViewModel.searchTerm = recent
                    } label: {
                        Text(recent)
                            .foregroundStyle(Color.primary)
                            .font(.caption)
                            .padding(10)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
                    }
                    
                }
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            SearchBar(searchTerm: $tenantSearchViewModel.searchTerm,
                     isTextFieldFocused: _isTextFieldFocused,
                     onCancel: tenantSearchViewModel.onClose,
                     onSearch: {
                        tenantSearchViewModel.saveRecentSearch(searchTerm: tenantSearchViewModel.searchTerm)
                     })
            
            if (tenantSearchViewModel.sheeHeight != .fraction(0.1)) {
                NewFilter(
                    categories: tenantSearchViewModel.categories,
                    selectedCategories: $tenantSearchViewModel.selectedCategories,
                    isOpenNow: $tenantSearchViewModel.isOpenNow,
                    priceFilter: $tenantSearchViewModel.priceFilter
                )
                .onChange(of: tenantSearchViewModel.priceFilter) { _, _ in
                    tenantSearchViewModel.updateFilteredTenant()
                }
                .onChange(of: tenantSearchViewModel.isOpenNow) { _, _ in
                    tenantSearchViewModel.updateFilteredTenant()
                }
                
//                Filter(
//                    categories: tenantSearchViewModel.categories,
//                    selectedCategories: $tenantSearchViewModel.selectedCategories,
//                    maxPrice: $tenantSearchViewModel.maxPrice,
//                    isOpenNow: tenantSearchViewModel.isOpenNow)
//                .onChange(of: tenantSearchViewModel.selectedCategories) { _, _ in
//                    tenantSearchViewModel.updateFilteredTenant()
//                }
//                .onChange(of: tenantSearchViewModel.maxPrice) { _, _ in
//                    tenantSearchViewModel.updateFilteredTenant()
//                }
//                .onChange(of: tenantSearchViewModel.isOpenNow) { _, _ in
//                    tenantSearchViewModel.updateFilteredTenant()
//                }
                
                ScrollView(.vertical) {
                    //Recent search (max 5)
                    if !tenantSearchViewModel.recentSearch.isEmpty {
                        showRecentSearch()
                    }
                    VStack {
                        showTenant(tenants: tenantSearchViewModel.doSearch(searchTerm: tenantSearchViewModel.searchTerm))
                    }
                    .padding(.top, tenantSearchViewModel.recentSearch.isEmpty ? 0 : 10)
                }
            }
        }
        .padding()
        .presentationDetents([.fraction(0.1), .fraction(0.95), .fraction(0.95)], selection: $tenantSearchViewModel.sheeHeight)
        .interactiveDismissDisabled()
        .presentationBackgroundInteraction(.enabled(upThrough: maxHeight))
        .onChange(of: isTextFieldFocused, initial: false) { _, newValue in
            withAnimation {
                tenantSearchViewModel.sheeHeight = newValue ? .fraction(0.95) : .fraction(0.1)
            }
        }
        .onChange(of: tenantSearchViewModel.sheeHeight) { _, newValue in
            if newValue == .fraction(0.1) {
                isTextFieldFocused = false
                tenantSearchViewModel.onClose()
            }
        }

    }
}










