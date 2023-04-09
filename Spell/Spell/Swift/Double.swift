//
//  Double.swift
//  Spell
//
//  Created by Andre Pham on 20/3/2023.
//

import Foundation

extension Double {
    
    func toString(decimalPlaces: Int = 2) -> String {
        return NSString(format: "%.\(decimalPlaces)f" as NSString, self) as String
    }
    
}
