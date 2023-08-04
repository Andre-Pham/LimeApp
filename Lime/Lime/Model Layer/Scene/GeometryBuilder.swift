//
//  GeometryBuilder.swift
//  Spell
//
//  Created by Andre Pham on 17/3/2023.
//

import Foundation
import SceneKit

class GeometryBuilder {
    
    private var applyToNode: (_ node: SCNNode) -> Void = { node in /* Do nothing */ }
    
    private init() { }
    
    func apply(to node: SCNNode) {
        self.applyToNode(node)
    }
    
    static func floor() -> GeometryBuilder {
        let builder = GeometryBuilder()
        builder.applyToNode = { node in
            node.geometry = SCNFloor()
        }
        return builder
    }
    
    static func line(origin: SCNVector3, end: SCNVector3) -> GeometryBuilder {
        let builder = GeometryBuilder()
        let source = SCNGeometrySource(vertices: [origin, end])
        let indices: [Int32] = [0, 1]
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        builder.applyToNode = { node in
            node.geometry = SCNGeometry(sources: [source], elements: [element])
        }
        return builder
    }
    
    static func cylinder(origin: SCNVector3, end: SCNVector3, radius: Double) -> GeometryBuilder {
        let builder = GeometryBuilder()
        let height = CGFloat(GLKVector3Distance(SCNVector3ToGLKVector3(origin), SCNVector3ToGLKVector3(end)))
        
        let startNode = SCNNode()
        let endNode = SCNNode()
        startNode.position = origin
        endNode.position = end
        
        let zAxisNode = SCNNode()
        zAxisNode.eulerAngles.x = Float(CGFloat(Double.pi/2))
        
        let cylinderGeometry = SCNCylinder(radius: radius, height: height)
        let cylinder = SCNNode(geometry: cylinderGeometry)
        cylinder.position.y = Float(-height/2)
        zAxisNode.addChildNode(cylinder)
        
        builder.applyToNode = { node in
            endNode.addChildNode(zAxisNode)
            endNode.constraints = [ SCNLookAtConstraint(target: startNode) ]
            node.addChildNode(endNode)
        }
        
        return builder
    }
    
    static func sphere(position: SCNVector3, radius: Double) -> GeometryBuilder {
        let builder = GeometryBuilder()
        builder.applyToNode = { node in
            node.geometry = SCNSphere(radius: radius)
            node.position = position
        }
        return builder
    }
    
}
