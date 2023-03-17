//
//  SCNVector3.swift
//  Spell
//
//  Created by Andre Pham on 18/3/2023.
//

import Foundation
import SceneKit

extension SCNVector3 {
    
    var normalized: SCNVector3 {
        let length = sqrt(pow(self.x, 2) + pow(self.y, 2) + pow(self.z, 2))
        return SCNVector3(self.x / length, self.y / length, self.z / length)
    }
    
    func length3D(to vector: SCNVector3) -> Float {
        return(sqrt(
            pow(vector.x - self.x, 2) +
            pow(vector.y - self.y, 2) +
            pow(vector.z - self.z, 2)
        ))
    }
    
    func crossProduct(with vector: SCNVector3) -> SCNVector3 {
        return SCNVector3(
            self.y * vector.z - self.z * vector.y,
            self.z * vector.x - self.x * vector.z,
            self.x * vector.y - self.y * vector.x
        )
    }
    
}
