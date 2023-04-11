//
//  SceneModel.swift
//  Spell
//
//  Created by Andre Pham on 9/4/2023.
//

import Foundation
import SceneKit

class SceneModel {
    
    public static let NAME_PREFIX = "model"
    
    private var node: SCNNode = SCNNode()
    var name: String {
        return self.node.name!
    }
    
    init(dir: String = "Models.scnassets", fileName: String) {
        if let scene = SCNScene(named: "\(dir)/\(fileName)"){
            for childNode in scene.rootNode.childNodes {
                self.node.addChildNode(childNode)
            }
        } else {
            assertionFailure("File '\(fileName)' could not be loaded from \(dir)")
        }
        self.node.name = "\(Self.NAME_PREFIX)-\(fileName)"
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
