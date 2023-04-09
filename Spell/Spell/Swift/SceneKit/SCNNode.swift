//
//  SCNNode.swift
//  Spell
//
//  Created by Andre Pham on 20/3/2023.
//

import Foundation
import SceneKit

extension SCNNode {
    
    func toString(position: Bool = true, bounding: Bool = true) -> String {
        let x = self.position.x.toString()
        let y = self.position.y.toString()
        let z = self.position.z.toString()
        let positionString = " | Position: (\(x), \(y), \(z))"
        let boundingString = " | Bounding: \(self.boundingBox.min.toString()), \(self.boundingBox.max.toString())"
        var result = "\(self.name ?? "nil")"
        if position {
            result += positionString
        }
        if bounding {
            result += boundingString
        }
        return result
    }
    
}
