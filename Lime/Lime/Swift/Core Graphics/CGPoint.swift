//
//  CGPoint.swift
//  Lime
//
//  Created by Andre Pham on 21/9/2023.
//

import Foundation

extension CGPoint {
    
    static func += (left: inout CGPoint, right: CGPoint) {
        left.x += right.x
        left.y += right.y
    }

    static func -= (left: inout CGPoint, right: CGPoint) {
        left.x -= right.x
        left.y -= right.y
    }
    
    func length(to point: CGPoint) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return sqrt(dx * dx + dy * dy)
    }
    
    func toString() -> String {
        return "(\(self.x.toString(decimalPlaces: 2)), \(self.y.toString(decimalPlaces: 2)))"
    }
    
}
