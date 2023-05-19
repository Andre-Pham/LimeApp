//
//  SCNVector4.swift
//  Spell
//
//  Created by Andre Pham on 18/5/2023.
//

import Foundation
import SceneKit

extension SCNVector4 {
    
    public static func == (lhs: SCNVector4, rhs: SCNVector4) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z && lhs.w == rhs.w
    }
    
    public static func != (lhs: SCNVector4, rhs: SCNVector4) -> Bool {
        return !(lhs == rhs)
    }
    
    func toString() -> String {
        return "(\(self.x.toString(decimalPlaces: 3)), \(self.y.toString(decimalPlaces: 3)), \(self.z.toString(decimalPlaces: 3)), \(self.w.toString(decimalPlaces: 3)))"
    }
    
}
