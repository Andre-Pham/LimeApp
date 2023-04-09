//
//  Float.swift
//  Spell
//
//  Created by Andre Pham on 20/3/2023.
//

import Foundation

extension Float {
    
    func toString(decimalPlaces: Int = 2) -> String {
        return NSString(format: "%.\(decimalPlaces)f" as NSString, self) as String
    }
    
}
