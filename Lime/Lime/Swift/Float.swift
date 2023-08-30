//
//  Float.swift
//  Lime
//
//  Created by Andre Pham on 20/3/2023.
//

import Foundation

extension Float {
    
    func toString(decimalPlaces: Int = 2) -> String {
        return NSString(format: "%.\(decimalPlaces)f" as NSString, self) as String
    }
    
    /// Round to x decimal places.
    /// Example: `0.545.rounded(decimalPlaces: 1) -> 0.5`
    /// - Parameters:
    ///   - decimalPlaces: The number of digits after the decimal point
    /// - Returns: The rounded double
    func rounded(decimalPlaces: Int) -> Float {
        let multiplier = pow(10.0, Float(decimalPlaces))
        return Darwin.round(self*multiplier)/multiplier
    }
    
}
