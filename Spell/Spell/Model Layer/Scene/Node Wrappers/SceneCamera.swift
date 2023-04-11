//
//  SceneCamera.swift
//  Spell
//
//  Created by Andre Pham on 17/3/2023.
//

import Foundation
import SceneKit

class SceneCamera {
    
    public static let NAME = "camera"
    
    private let node = SCNNode()
    private let camera = SCNCamera()
    private var sceneView: SCNView? = nil
    var name: String {
        return self.node.name!
    }
    
    init() {
        self.node.name = Self.NAME
        self.node.camera = self.camera
    }
    
    func add(to sceneView: SCNView) {
        sceneView.scene?.rootNode.addChildNode(self.node)
        sceneView.pointOfView = self.node
        self.sceneView = sceneView
    }
    
    func remove() {
        self.node.removeFromParentNode()
        self.sceneView = nil
    }
    
    @discardableResult
    func setPosition(to position: SCNVector3) -> Self {
        self.node.position = position
        self.sceneView?.pointOfView = self.node
        return self
    }
    
    @discardableResult
    func direct(to position: SCNVector3) -> Self {
        self.node.look(at: position)
        self.sceneView?.pointOfView = self.node
        return self
    }
    
    @discardableResult
    func setRenderDistance(far: Double? = nil, near: Double? = nil) -> Self {
        if let far {
            self.camera.zFar = far
        }
        if let near {
            self.camera.zNear = near
        }
        return self
    }
    
}
