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
    
    func addMaterial(named materialName: String?, childNode: PresetNode? = nil, _ callback: (_ material: SCNMaterial) -> Void) {
        var geometry: SCNGeometry? = nil
        if childNode == nil {
            geometry = self.node.geometry
        } else if let targetedNode = self.node.childNode(withName: childNode!.name, recursively: true) {
            geometry = targetedNode.geometry
        } else {
            assertionFailure("Node could not be found")
        }
        guard let geometry else {
            assertionFailure("Geometry could not be defined")
            return
        }
        let newMaterial = SCNMaterial()
        newMaterial.name = materialName
        geometry.materials.append(newMaterial)
        callback(newMaterial)
    }
    
    func editMaterial(named materialName: String? = nil, childNode: PresetNode? = nil, _ callback: (_ material: SCNMaterial) -> Void) {
        var geometry: SCNGeometry? = nil
        if childNode == nil {
            geometry = self.node.geometry
        } else if let targetedNode = self.node.childNode(withName: childNode!.name, recursively: true) {
            geometry = targetedNode.geometry
        } else {
            assertionFailure("Node could not be found")
        }
        guard let geometry else {
            assertionFailure("Geometry could not be defined")
            return
        }
        if let materialName {
            if let material = geometry.material(named: materialName) {
                callback(material)
            } else {
                assertionFailure("No material with matching name found")
            }
        } else if let material = geometry.firstMaterial {
            callback(material)
        } else {
            assertionFailure("Geometry has no material")
        }
    }
    
}
