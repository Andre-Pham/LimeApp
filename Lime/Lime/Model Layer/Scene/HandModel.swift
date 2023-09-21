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
    
    /// The name of the node that should contain the animation player
    private static let ANIMATED_NODE_NAME = "Armature"
    /// The animation key of the animation imported along with the model
    private static let ANIMATED_KEY = "action_container-Armature"
    
    // MARK: - Node Properties
    
    /// The name prefix of the node name
    public let namePrefix = "hand-model"
    /// The wrapped node
    private(set) var node: SCNNode = SCNNode()
    /// The node name
    public var name: String {
        return self.node.name!
    }
    /// The blend in animation originally set
    public let defaultBlendInDuration: Double
    /// This class' node's animated child node
    private var animatedNode: SCNNode {
        return self.node.childNode(withName: Self.ANIMATED_NODE_NAME, recursively: true)!
    }
    /// This class' node's animated child node's animation player
    public var animationPlayer: SCNAnimationPlayer {
        return self.animatedNode.animationPlayer(forKey: Self.ANIMATED_KEY)!
    }
    /// The total duration of the animation
    public var animationDuration: Double {
        return self.animationPlayer.animation.duration
    }
    /// The total duration of the animation, accounting for it "ending" when it begins to blend
    public var animationDurationBlended: Double {
        return self.animationPlayer.animation.duration - self.defaultBlendInDuration
    }
    
    /// Example:
    /// `HandModel(subDir: "alphabet1", fileName: "a_1.dae", blendInDuration: 0.5)`
    /// - Parameters:
    ///   - dir: The main directory where the model's scene assets are located. Default is "Models.scnassets"
    ///   - subDir: An optional sub-directory within `dir` where the model's scene assets are located
    ///   - fileName: The file name of the model's scene file (include extension)
    ///   - name: An optional name for the mode (If not provided, a name will be generated)
    ///   - blendInDuration: The duration to blend animations in seconds
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
        self.animationPlayer.animation.repeatCount = 1
        self.animationPlayer.animation.isRemovedOnCompletion = false
    }
    
    /// Add an animation player to this model.
    /// - Parameters:
    ///   - animationPlayer: The animation player to be added
    ///   - key: The key to set for the animation player
    func addAnimation(animationPlayer: SCNAnimationPlayer, key: String) {
        self.animatedNode.addAnimationPlayer(animationPlayer, forKey: key)
    }
    
    /// Set the blend in duration for this model.
    /// By default resets the blend in duration back to the original value.
    /// - Parameters:
    ///   - duration: The blend in duration (set to nil to return to original)
    func setBlendInDuration(to duration: Double? = nil) {
        self.animationPlayer.animation.blendInDuration = duration ?? self.defaultBlendInDuration
    }
    
}
