//
//  ModelRotationsIndex.swift
//  Lime
//
//  Created by Andre Pham on 1/6/2023.
//

import Foundation
import SceneKit

class ModelRotationsIndex {
    
    private var rotations = [String: SCNVector4]()
    
    func addRotation(nodeName: String, rotation: SCNVector4) {
        self.rotations[nodeName] = rotation
    }
    
    func getRotation(nodeName: String) -> SCNVector4? {
        return self.rotations[nodeName]
    }
    
    func getHandRotation(relativeTo: ModelRotationsIndex) -> Float {
        var totalRotation: Float = 0.0
        for key in self.rotations.keys {
            // TODO: Convert strings to preset enum values
            guard ["hand-L", "hand-R"].contains(key) else {
                continue
            }
            if let r1 = self.rotations[key], let r2 = relativeTo.rotations[key] {
                totalRotation += r1.rotationMagnitude(r2)
            }
        }
        return totalRotation
    }
    
}
