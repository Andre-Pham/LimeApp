//
//  HandModel.swift
//  Lime
//
//  Created by Andre Pham on 2/9/2023.
//

import Foundation
import SceneKit

class HandModel: SceneModel {
    
    // MARK: - Constants
    
    private static let ANIMATED_NODE_NAME = "Armature"
    private static let ANIMATED_KEY = "action_container-Armature"
    
    // MARK: - Node Properties
    
    public let namePrefix = "hand-model"
    private(set) var node: SCNNode = SCNNode()
    public var name: String {
        return self.node.name!
    }
    private let defaultBlendInDuration: Double
    private var animatedNode: SCNNode {
        return self.node.childNode(withName: Self.ANIMATED_NODE_NAME, recursively: true)!
    }
    public var animationPlayer: SCNAnimationPlayer {
        return self.animatedNode.animationPlayer(forKey: Self.ANIMATED_KEY)!
    }
    public var animationDuration: Double {
        return self.animationPlayer.animation.duration
    }
    public var animationDurationBlended: Double {
        return self.animationPlayer.animation.duration - self.defaultBlendInDuration
    }
    
    init(
        dir: String = "Models.scnassets",
        subDir: String? = nil,
        fileName: String,
        name: String? = nil,
        blendInDuration: Double
    ) {
        let directory = subDir == nil ? "\(dir)/\(fileName)" : "\(dir)/\(subDir!)/\(fileName)"
        if let scene = SCNScene(named: directory) {
            for childNode in scene.rootNode.childNodes {
                self.node.addChildNode(childNode)
            }
        } else {
            assertionFailure("File '\(fileName)' could not be loaded from \(dir)")
        }
        self.defaultBlendInDuration = blendInDuration
        self.node.name = (name == nil ? "\(self.namePrefix)-\(fileName)" : "\(self.namePrefix)-\(name!)")
        self.animationPlayer.animation.blendInDuration = blendInDuration
    }
    
    func addAnimation(animationPlayer: SCNAnimationPlayer, key: String) {
        self.animatedNode.addAnimationPlayer(animationPlayer, forKey: key)
    }
    
    func setBlendInDuration(to duration: Double? = nil) {
        self.animationPlayer.animation.blendInDuration = duration ?? self.defaultBlendInDuration
    }
    
}
