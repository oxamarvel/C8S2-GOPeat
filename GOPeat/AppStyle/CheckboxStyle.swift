//
//  CheckboxStyle.swift
//  GOPeat
//
//  Created by Oxa Marvel on 17/05/25.
//

import SwiftUI


struct CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .font(.system(size: 30))
                .foregroundColor(.black)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}
