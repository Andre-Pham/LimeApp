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
    
    func apply(to node: SCNNode) {
        self.applyToNode(node)
    }
    
    func floor() -> Self {
        self.applyToNode = { node in
            node.geometry = SCNFloor()
        }
        return self
    }
    
    func line(origin: SCNVector3, end: SCNVector3) -> Self {
        let source = SCNGeometrySource(vertices: [origin, end])
        let indices: [Int32] = [0, 1]
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        self.applyToNode = { node in
            node.geometry = SCNGeometry(sources: [source], elements: [element])
        }
        return self
    }
    
    func cylinder(origin: SCNVector3, end: SCNVector3, radius: Double) -> Self {
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
        
        self.applyToNode = { node in
            if (origin.x > 0.0 && origin.y < 0.0 && origin.z < 0.0 && end.x > 0.0 && end.y < 0.0 && end.z > 0.0) {
                endNode.addChildNode(zAxisNode)
                endNode.constraints = [ SCNLookAtConstraint(target: startNode) ]
                node.addChildNode(endNode)
            } else if (origin.x < 0.0 && origin.y < 0.0 && origin.z < 0.0 && end.x < 0.0 && end.y < 0.0 && end.z > 0.0) {
                endNode.addChildNode(zAxisNode)
                endNode.constraints = [ SCNLookAtConstraint(target: startNode) ]
                node.addChildNode(endNode)
            } else if (origin.x < 0.0 && origin.y > 0.0 && origin.z < 0.0 && end.x < 0.0 && end.y > 0.0 && end.z > 0.0) {
                endNode.addChildNode(zAxisNode)
                endNode.constraints = [ SCNLookAtConstraint(target: startNode) ]
                node.addChildNode(endNode)
            } else if (origin.x > 0.0 && origin.y > 0.0 && origin.z < 0.0 && end.x > 0.0 && end.y > 0.0 && end.z > 0.0) {
                endNode.addChildNode(zAxisNode)
                endNode.constraints = [ SCNLookAtConstraint(target: startNode) ]
                node.addChildNode(endNode)
            } else {
                startNode.addChildNode(zAxisNode)
                startNode.constraints = [ SCNLookAtConstraint(target: endNode) ]
                node.addChildNode(startNode)
            }
        }
        
        return self
    }
    
    func sphere(position: SCNVector3, radius: Double) -> Self {
        self.applyToNode = { node in
            node.geometry = SCNSphere(radius: radius)
            node.position = position
        }
        return self
    }
    
}
