//
//  SceneGeometry.swift
//  Spell
//
//  Created by Andre Pham on 17/3/2023.
//

import Foundation
import SceneKit

class SceneGeometry {
    
    private static let NAME_PREFIX = "geometry"
    
    private var node: SCNNode = SCNNode()
    private var geometry: SCNGeometry = SCNGeometry()
    var name: String {
        return self.node.name!
    }
    
    init(id: String = UUID().uuidString) {
        self.node.geometry = self.geometry
        self.node.name = "\(Self.NAME_PREFIX)-\(id)"
    }
    
    init(id: String = UUID().uuidString, geometry: SCNGeometry) {
        self.setGeometry(to: geometry)
        self.node.name = "\(Self.NAME_PREFIX)-\(id)"
    }
    
    func add(to sceneView: SCNView) {
        sceneView.scene?.rootNode.addChildNode(self.node)
    }
    
    func remove() {
        self.node.removeFromParentNode()
    }
    
    @discardableResult
    func setGeometry(to geometry: SCNGeometry) -> Self {
        self.node.geometry = geometry
        self.geometry = geometry
        return self
    }
    
    @discardableResult
    func setLightingModel(to lightingModel: SCNMaterial.LightingModel) -> Self {
        self.node.geometry?.firstMaterial?.lightingModel = lightingModel
        return self
    }
    
    @discardableResult
    func setColor(to color: UIColor) -> Self {
        self.node.geometry?.firstMaterial?.diffuse.contents = color
        return self
    }
    
}
