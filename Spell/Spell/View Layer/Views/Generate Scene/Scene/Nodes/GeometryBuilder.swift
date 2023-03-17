//
//  GeometryBuilder.swift
//  Spell
//
//  Created by Andre Pham on 17/3/2023.
//

import Foundation
import SceneKit

enum GeometryBuilder {
    
    static func floor() -> SCNGeometry {
        return SCNFloor()
    }
    
    static func line(origin: SCNVector3, end: SCNVector3) -> SCNGeometry {
        let source = SCNGeometrySource(vertices: [origin, end])
        let indices: [Int32] = [0, 1]
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
    
}
