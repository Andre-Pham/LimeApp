//
//  SceneModel.swift
//  Lime
//
//  Created by Andre Pham on 9/4/2023.
//

import Foundation
import SceneKit

protocol SceneModel {
    
    var namePrefix: String { get }
    var node: SCNNode { get }
    var name: String { get }
    
}
extension SceneModel {
    
    func rename(to name: String) {
        self.node.name = "\(self.namePrefix)-\(name)"
        assert(self.name == self.node.name, "Node name and name should match")
    }
    
    func add(to sceneView: SCNView) {
        sceneView.scene?.rootNode.addChildNode(self.node)
    }
    
    func remove() {
        self.node.removeFromParentNode()
    }
    
    func setOpacity(to opacity: Double) {
        self.node.opacity = opacity
    }
    
    func addMaterial(named materialName: String?, childNode: String? = nil, _ callback: (_ material: SCNMaterial) -> Void) {
        var geometry: SCNGeometry? = nil
        if childNode == nil {
            geometry = self.node.geometry
        } else if let targetedNode = self.node.childNode(withName: childNode!, recursively: true) {
            geometry = targetedNode.geometry
        }
        if let geometry {
            let newMaterial = SCNMaterial()
            newMaterial.name = materialName
            geometry.materials.append(newMaterial)
            callback(newMaterial)
        }
    }
    
    func editMaterial(named materialName: String? = nil, childNode: String? = nil, _ callback: (_ material: SCNMaterial) -> Void) {
        var geometry: SCNGeometry? = nil
        if childNode == nil {
            geometry = self.node.geometry
        } else if let targetedNode = self.node.childNode(withName: childNode!, recursively: true) {
            geometry = targetedNode.geometry
        }
        guard let geometry else {
            return
        }
        if let materialName {
            if let material = geometry.material(named: materialName) {
                callback(material)
            }
        } else if let material = geometry.firstMaterial {
            callback(material)
        }
    }
    
}
