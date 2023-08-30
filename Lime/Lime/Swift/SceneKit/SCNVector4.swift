//
//  SCNVector4.swift
//  Lime
//
//  Created by Andre Pham on 18/5/2023.
//

import Foundation
import SceneKit

extension SCNVector4 {
    
    static func == (lhs: SCNVector4, rhs: SCNVector4) -> Bool {
        return isEqual(lhs.x, rhs.x) && isEqual(lhs.y, rhs.y) && isEqual(lhs.z, rhs.z) && isEqual(lhs.w, rhs.w)
    }
    
    static func != (lhs: SCNVector4, rhs: SCNVector4) -> Bool {
        return !(lhs == rhs)
    }
    
    var normalized: SCNVector4 {
        let length = sqrt(self.x*self.x + self.y*self.y + self.z*self.z + self.w*self.w)
        guard length > 0 else { return self }
        return SCNVector4(x: self.x/length, y: self.y/length, z: self.z/length, w: self.w/length)
    }
    
    func dotProduct(_ v: SCNVector4) -> Float {
        return self.x * v.x + self.y * v.y + self.z * v.z + self.w * v.w
    }
    
    func rotationMagnitude(_ v: SCNVector4) -> Float {
        let dotProductVal = self.normalized.dotProduct(v.normalized).rounded(decimalPlaces: 5)
        let angle = acos(2 * pow(dotProductVal, 2) - 1)
        return angle
    }
    
    func toString() -> String {
        return "(\(self.x.toString(decimalPlaces: 3)), \(self.y.toString(decimalPlaces: 3)), \(self.z.toString(decimalPlaces: 3)), \(self.w.toString(decimalPlaces: 3)))"
    }
    
}
