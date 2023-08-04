//
//  SCNNode.swift
//  Lime
//
//  Created by Andre Pham on 20/3/2023.
//

import Foundation
import SceneKit

extension SCNNode {
    
    func hasBoundingBox() -> Bool {
        let min = self.boundingBox.min
        let max = self.boundingBox.max
        let width = max.x - min.x
        let height = max.y - min.y
        let depth = max.z - min.z
        return isGreaterZero(width*height*depth)
    }
    
    func toString(position: Bool = false, bounding: Bool = false, animation: Bool = false) -> String {
        let x = self.position.x.toString()
        let y = self.position.y.toString()
        let z = self.position.z.toString()
        var result = "\(self.name ?? "nil")"
        if position {
            result += " | Position: (\(x), \(y), \(z))"
        }
        if bounding {
            let boundingString = self.hasBoundingBox() ? "\(self.boundingBox.min.toString()), \(self.boundingBox.max.toString())" : "None"
            result += " | Bounding: \(boundingString)"
        }
        if animation {
            var animations = [String]()
            self.animationKeys.forEach({ key in
                if let _ = self.animationPlayer(forKey: key) {
                    animations.append(key)
                }
            })
            result += " | Animations: \(animations)"
        }
        return result
    }
    
}
