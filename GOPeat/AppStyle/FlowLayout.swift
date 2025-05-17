//
//  FlowLayout.swift
//  GOPeat
//
//  Created by Oxa Marvel on 17/05/25.
//

import SwiftUI


struct FlowLayout<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var rows: [[Data.Element]] = [[]]

        for item in data {
            let itemSize = content(item)
                .fixedSize()
                .background(GeometryReader { geo in
                    Color.clear.preference(key: SizePreferenceKey.self, value: geo.size)
                })

            let itemWidth: CGFloat = estimateTextWidth(item) + 32 // estimate padding

            if width + itemWidth > geometry.size.width {
                width = 0
                rows.append([item])
                width += itemWidth + spacing
            } else {
                rows[rows.count - 1].append(item)
                width += itemWidth + spacing
            }
        }

        return VStack(alignment: .leading, spacing: spacing) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(row, id: \.self) { item in
                        content(item)
                    }
                }
            }
        }
    }

    private func estimateTextWidth(_ item: Data.Element) -> CGFloat {
        let string = String(describing: item)
        return CGFloat(string.count * 8)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
