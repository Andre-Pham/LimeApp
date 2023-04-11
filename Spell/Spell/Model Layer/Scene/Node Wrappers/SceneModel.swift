//
//  SceneModel.swift
//  Spell
//
//  Created by Andre Pham on 9/4/2023.
//

import Foundation
import SceneKit

class SceneModel {
    
    private static let NAME_PREFIX = "model"
    
    private var node: SCNNode = SCNNode()
    var name: String {
        return self.node.name!
    }
    
    init(file: String) {
        if let scene = SCNScene(named: file){
            for childNode in scene.rootNode.childNodes {
                self.node.addChildNode(childNode)
            }
        } else {
            assertionFailure("File '\(file)' could not be loaded")
        }
        self.node.name = "\(Self.NAME_PREFIX)-\(file)"
    }
    
    func add(to sceneView: SCNView) {
        sceneView.scene?.rootNode.addChildNode(self.node)
    }
    
    func remove() {
        self.node.removeFromParentNode()
    }
    
    func setAnimationSpeed(to speed: Double) {
        for node in NodeUtil.getHierarchy(for: self.node) {
            node.animationKeys.forEach({ key in
                if let animation = node.animationPlayer(forKey: key) {
                    animation.speed = speed
                }
            })
        }
    }
    
}
