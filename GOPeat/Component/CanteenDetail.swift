//
//  CanteenDetail.swift
//  GOPeat
//
//  Created by jonathan calvin sutrisna on 07/04/25.
//

import SwiftUI
import MapKit
import SwiftData

struct CanteenDetail: View {
    let canteen: Canteen
    var dismissAction: () -> Void
    @StateObject var viewModel: TenantSearchViewModel
    
    init(canteen: Canteen, dismissAction: @escaping () -> Void) {
        self.canteen = canteen
        self.dismissAction = dismissAction
        self._viewModel = StateObject(wrappedValue: TenantSearchViewModel(tenants: canteen.tenants))
    }
    
    private func showTenant(tenants: [Tenant]) -> some View {
        VStack(alignment: .leading) {
            Text("Tenants")
                .font(.headline)
                .fontWeight(.bold)
                .padding(0)
            Divider()
            if !tenants.isEmpty {
                ForEach(tenants) {tenant in
                    TenantCard(tenant: tenant, selectedCategories: $viewModel.selectedCategories)
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

    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack(alignment: .top) {
                        Image(systemName: "fork.knife.circle.fill")
                            .foregroundStyle(.red)
                            .font(.system(size: 36))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(canteen.name)
                                .font(.title2)
                                .bold()
                            
                            Text(canteen.desc)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.bottom, 8)
                    
                    Divider()
                    
                    // Hours Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("OPERATING HOURS")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(canteen.operationalTime)
                            .font(.subheadline)
                    }
                    
                    Divider()
                    
                    // Amenities Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AMENITIES")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                            ForEach(canteen.amenities, id: \.self) { amenity in
                                Label(amenity, systemImage: amenityIcon(for: amenity))
                                    .font(.subheadline)
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    
                    Divider()
                    //Filter Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("FILTER")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        NewFilter()
                        
                        Filter(categories: viewModel.categories, selectedCategories: $viewModel.selectedCategories, maxPrice: $viewModel.maxPrice, isOpenNow: $viewModel.isOpenNow)
                            .onChange(of: viewModel.selectedCategories) { _, _ in
                                viewModel.updateFilteredTenant()
                            }
                            .onChange(of: viewModel.maxPrice) { _, _ in
                                viewModel.updateFilteredTenant()
                            }
                            .onChange(of: viewModel.isOpenNow) { _, _ in
                                viewModel.updateFilteredTenant()
                            }
                    }
                    
                    // Tenants Section
                    if canteen.tenants.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Tenants")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(0)
                            Divider()
                            Text("Coming Soon")
                                .font(.subheadline.bold())
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        }
                    } else {
                        showTenant(tenants: viewModel.filteredTenants)
                    }
                }
                .padding()
            }
            .navigationTitle("Location Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done", action: dismissAction)
                }
            }
        }
    }
    
    private func amenityIcon(for amenity: String) -> String {
        switch amenity {
        case "Free WiFi": return "wifi"
        case "Air Conditioned": return "air.conditioner.horizontal"
        case "Outdoor Seating": return "table.furniture"
        case "ATM": return "banknote"
        case "Printing Services": return "printer"
        case "Disabled Access": return "figure.roll"
        case "Smoking Area": return "smoke"
        case "Convenience Store": return "cart"
        case "Live Music": return "music.mic"
        case "Event Space": return "calendar"
        case "Premium Dining": return "star"
        case "Prayer Room": return "hands.and.sparkles" // Added prayer room icon
        default: return "mappin"
        }
    }
}

