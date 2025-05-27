//
//  TenantCard.swift
//  GOPeat
//
//  Created by jonathan calvin sutrisna on 07/04/25.
//

import SwiftUI

struct TenantCard: View {
    let tenant: Tenant
    @State var showTenantDetail = false
    @Binding var selectedCategories: [String]
    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text("\(label):")
            Spacer()
            Text(value)
        }
        .font(.caption)
        .foregroundColor(.primary)
    }

    var body: some View {
        Button(action: {
            showTenantDetail = true
        }) {
            HStack(alignment: .bottom) {
                Image(tenant.image)
                    .resizable()
                    .frame(maxWidth: 80, maxHeight: 80)
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading) {
                    Text(tenant.name)
                        .font(.subheadline)
                        .bold()
                    Text(tenant.canteen?.name ?? "")
                        .font(.caption)
                    
                    Spacer()
                    
                    infoRow(label: "Operational Hours", value: tenant.operationalHours)
                    infoRow(label: "Average Spent", value: "Rp\(tenant.priceRange)")
                    
                    
                    
//                    infoRow(label: "Contact Person", value: tenant.contactPerson)
//                    infoRow(label: "Pre-order Information", value: "\((tenant.preorderInformation ?? false) ? "Available" : "Not available")")
                }
                
                
                if tenant.isHalal == true {
                    Image("halal")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.leading, 15)
                } else {
                    Image("halal")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .opacity(0)
                        .padding(.leading,15)
                }
                
            }
            .padding(10)
            .background(Color(.systemGray5).opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $showTenantDetail) {
            showTenantDetail = false
        } content: {
            TenantView(tenant: tenant, foods: tenant.foods, selectedCategories: $selectedCategories)
        }

    }
}
