//
//  FlowLayout.swift
//  GOPeat
//
//  Created by Oxa Marvel on 17/05/25.
//
//  Done


import SwiftUI


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
//        let maxWidth = bounds.width
        let _ = bounds.width

        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
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
