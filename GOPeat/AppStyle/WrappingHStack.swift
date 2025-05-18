//
//  FlowLayout.swift
//  GOPeat
//
//  Created by Oxa Marvel on 17/05/25.
//

import SwiftUI


//struct FlowLayout<Data: Collection, Content: View>: View where Data.Element: Hashable {
//    let data: Data
//    let spacing: CGFloat
//    let content: (Data.Element) -> Content
//
//    var body: some View {
//        GeometryReader { geometry in
//            self.generateContent(in: geometry)
//        }
//    }
//
//    private func generateContent(in geometry: GeometryProxy) -> some View {
//        var width: CGFloat = 0
//        var rows: [[Data.Element]] = [[]]
//
//        for item in data {
////            let itemSize = content(item)
//
//            let _ = content(item)
//                .fixedSize()
//                .background(GeometryReader { geo in
//                    Color.clear.preference(key: SizePreferenceKey.self, value: geo.size)
//                })
//
//            let itemWidth: CGFloat = estimateTextWidth(item) + 32 // estimate padding
//
//            if width + itemWidth > geometry.size.width {
//                width = 0
//                rows.append([item])
//                width += itemWidth + spacing
//            } else {
//                rows[rows.count - 1].append(item)
//                width += itemWidth + spacing
//            }
//        }
//
//        return VStack(alignment: .leading, spacing: spacing) {
//            ForEach(rows, id: \.self) { row in
//                HStack(spacing: spacing) {
//                    ForEach(row, id: \.self) { item in
//                        content(item)
//                    }
//                }
//            }
//        }
//    }
//
//    private func estimateTextWidth(_ item: Data.Element) -> CGFloat {
//        let string = String(describing: item)
//        return CGFloat(string.count * 8)
//    }
//}
//
//private struct SizePreferenceKey: PreferenceKey {
//    static var defaultValue: CGSize = .zero
//    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
//        value = nextValue()
//    }
//}








struct WrappingHStack: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity

        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var currentLineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth {
                currentX = 0
                currentY += currentLineHeight + lineSpacing
                currentLineHeight = 0
            }

            currentX += size.width + spacing
            currentLineHeight = max(currentLineHeight, size.height)
        }

        return CGSize(width: maxWidth, height: currentY + currentLineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width

        var x: CGFloat = bounds.minX  // Start at the bounds origin
        var y: CGFloat = bounds.minY  // Start at the bounds origin
        var currentLineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x + size.width > bounds.maxX {  // Compare against bounds.maxX
                x = bounds.minX
                y += currentLineHeight + lineSpacing
                currentLineHeight = 0
            }

            subview.place(
                at: CGPoint(x: x, y: y),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )

            x += size.width + spacing
            currentLineHeight = max(currentLineHeight, size.height)
        }
    }
}
