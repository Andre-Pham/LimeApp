//
//  SceneLight.swift
//  Lime
//
//  Created by Andre Pham on 13/3/2023.
//

import Foundation
import SceneKit

class SceneLight {
    
    public static let NAME_PREFIX = "light"
    
    private let node = SCNNode()
    private let light = SCNLight()
    var name: String {
        return self.node.name!
    }
    
    init(id: String = UUID().uuidString) {
        self.node.name = "\(Self.NAME_PREFIX)-\(id)"
        self.node.light = self.light
    }
    
    func add(to sceneView: SCNView) {
        sceneView.scene?.rootNode.addChildNode(self.node)
    }
    
    func remove() {
        self.node.removeFromParentNode()
    }
    
    @discardableResult
    func setPosition(to position: SCNVector3) -> Self {
        self.node.position = position
        return self
    }
    
    @discardableResult
    func setColor(to color: UIColor) -> Self {
        self.light.color = color
        return self
    }
    
    @discardableResult
    func setType(to type: SCNLight.LightType) -> Self {
        self.light.type = type
        return self
    }

}
