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
    
    func translate(_ translation: SCNVector3, animationDuration: Double? = nil) {
        if let duration = animationDuration {
            let action = SCNAction.move(by: translation, duration: duration)
            let sequence = SCNAction.sequence([action])
            self.node.presentation.runAction(sequence)
        } else {
            self.node.localTranslate(by: translation)
        }
        // The following resets the animation bounding box, hence it isn't included
        /*for node in NodeUtil.getHierarchy(for: self.node) {
            node.presentation.boundingBox.min += translation
            node.presentation.boundingBox.max += translation
        }*/
    }
    
//    func match(_ model: SceneModel, animationDuration: Double? = nil) {
//        // Obviously inefficient, will review later
//        for node in NodeUtil.getHierarchy(for: self.node) {
//            for otherNode in NodeUtil.getHierarchy(for: model.node) {
//                if node.name == otherNode.name {
//                    let translation = otherNode.presentation.position - node.presentation.position
//                    let action = SCNAction.move(by: translation, duration: animationDuration ?? 0.0)
//                    let sequence = SCNAction.sequence([action])
//                    node.presentation.runAction(sequence)
//                }
//            }
//        }
//    }
    
}
