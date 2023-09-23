//
//  CGFloat.swift
//  Lime
//
//  Created by Andre Pham on 21/9/2023.
//

import Foundation

extension CGFloat {
    
    func toString(decimalPlaces: Int = 2) -> String {
        return NSString(format: "%.\(decimalPlaces)f" as NSString, self) as String
    }
    
    /// Round to x decimal places.
    /// Example: `0.545.rounded(decimalPlaces: 1) -> 0.5`
    /// - Parameters:
    ///   - decimalPlaces: The number of digits after the decimal point
    /// - Returns: The rounded double
    func rounded(decimalPlaces: Int) -> CGFloat {
        let multiplier = pow(10.0, Double(decimalPlaces))
        return Darwin.round(self*multiplier)/multiplier
    }
    
}
