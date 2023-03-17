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
        self.allNodes().forEach({
            $0.geometry?.firstMaterial?.lightingModel = lightingModel
        })
        return self
    }
    
    @discardableResult
    func setColor(to color: UIColor) -> Self {
        self.allNodes().forEach({
            $0.geometry?.firstMaterial?.diffuse.contents = color
        })
        return self
    }
    
    private func allNodes() -> [SCNNode] {
        var allNodes = [SCNNode]()
        self.recursivelyFindNodes(for: self.node, insert: &allNodes)
        return allNodes
    }
    
    private func recursivelyFindNodes(for node: SCNNode, insert: inout [SCNNode]) {
        insert.append(node)
        for childNode in node.childNodes {
            self.recursivelyFindNodes(for: childNode, insert: &insert)
        }
    }
    
}
