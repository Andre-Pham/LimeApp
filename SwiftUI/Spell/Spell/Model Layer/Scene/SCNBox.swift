//
//  SCNBox.swift
//  Spell
//
//  Created by Andre Pham on 10/4/2023.
//

import Foundation
import SceneKit

class SCNBox {
    
    public let min: SCNVector3
    public let max: SCNVector3
    public var width: Float {
        self.max.x - self.min.x
    }
    public var height: Float {
        self.max.y - self.min.y
    }
    public var depth: Float {
        self.max.z - self.min.z
    }
    public var volume: Float {
        self.width*self.height*self.depth
    }
    public var centre: SCNVector3 {
        SCNVector3(
            (self.min.x + self.max.x)/2.0,
            (self.min.y + self.max.y)/2.0,
            (self.min.z + self.max.z)/2.0
        )
    }
    public var edges: [(SCNVector3, SCNVector3)] {
        let x = self.min.x, y = self.min.y, z = self.min.z
        let w = self.width, h = self.height, d = self.depth
        return [
            (SCNVector3(x, y, z), SCNVector3(x+w, y, z)),           (SCNVector3(x, y, z), SCNVector3(x, y, z+d)),
            (SCNVector3(x, y, z), SCNVector3(x, y+h, z)),           (SCNVector3(x+w, y, z), SCNVector3(x+w, y+h, z)),
            (SCNVector3(x, y, z+d), SCNVector3(x, y+h, z+d)),       (SCNVector3(x, y+h, z), SCNVector3(x+w, y+h, z)),
            (SCNVector3(x, y+h, z), SCNVector3(x, y+h, z+d)),       (SCNVector3(x, y, z+d), SCNVector3(x+w, y, z+d)),
            (SCNVector3(x+w, y, z), SCNVector3(x+w, y, z+d)),       (SCNVector3(x+w, y+h, z), SCNVector3(x+w, y+h, z+d)),
            (SCNVector3(x, y+h, z+d), SCNVector3(x+w, y+h, z+d)),   (SCNVector3(x+w, y, z+d), SCNVector3(x+w, y+h, z+d)),
        ]
    }
    
    init?(node: SCNNode) {
        self.min = node.presentation.boundingBox.min
        self.max = node.presentation.boundingBox.max
        guard isGreaterZero(self.volume) else {
            return nil
        }
    }
    
}
