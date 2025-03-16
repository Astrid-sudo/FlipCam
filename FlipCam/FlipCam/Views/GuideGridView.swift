//
//  GuideGridView.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/16.
//

import SwiftUI

struct GridLines: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Draw vertical lines
        let columnWidth = rect.width / 3
        for i in 1...2 {
            let x = columnWidth * CGFloat(i)
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }
        
        // Draw horizontal lines
        let rowHeight = rect.height / 3
        for i in 1...2 {
            let y = rowHeight * CGFloat(i)
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        
        return path
    }
}
