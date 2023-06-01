//
//  ModelRotationsIndex.swift
//  Spell
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
    
}
