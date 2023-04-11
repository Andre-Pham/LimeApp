//
//  SceneGeometry.swift
//  Spell
//
//  Created by Andre Pham on 17/3/2023.
//

import Foundation
import SceneKit

class SceneGeometry {
    
    public static let NAME_PREFIX = "geometry"
    
    private var node: SCNNode = SCNNode()
    var name: String {
        return self.node.name!
    }
    
    init(id: String = UUID().uuidString) {
        self.node.name = "\(Self.NAME_PREFIX)-\(id)"
    }
    
    init(id: String = UUID().uuidString, geometry: GeometryBuilder) {
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
    func setGeometry(to geometryBuilder: GeometryBuilder) -> Self {
        geometryBuilder.apply(to: self.node)
        return self
    }
    
    @discardableResult
    func setLightingModel(to lightingModel: SCNMaterial.LightingModel) -> Self {
        NodeUtil.getHierarchy(for: self.node).forEach({
            $0.geometry?.firstMaterial?.lightingModel = lightingModel
        })
        return self
    }
    
    @discardableResult
    func setColor(to color: UIColor) -> Self {
        NodeUtil.getHierarchy(for: self.node).forEach({
            $0.geometry?.firstMaterial?.diffuse.contents = color
        })
        return self
    }
    
    @discardableResult
    func setOpacity(to opacity: Double) -> Self {
        self.node.opacity = opacity
        return self
    }
    
}
