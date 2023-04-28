//
//  SceneModel.swift
//  Spell
//
//  Created by Andre Pham on 9/4/2023.
//

import Foundation
import SceneKit

class SceneModel {
    
    // MARK: - Constants
    
    public static let NAME_PREFIX = "model"
    
    // MARK: - Node Properties
    
    private var node: SCNNode = SCNNode()
    var name: String {
        return self.node.name!
    }
    
    // MARK: - Animation Properties
    
    /// All animation players used within the model
    private var animationPlayers = [SCNAnimationPlayer]()
    /// The total length of the animation (seconds)
    private let animationDuration: Double
    /// The progress through the model's animation (seconds)
    private var animationProgress: Double = 0.0
    /// The speed multiplier on the model's animation
    private(set) var animationSpeed = 1.0
    /// The timer used to measure time between Timer intervals
    /// Found to be more accurate than using the time interval itself
    private var timer: DispatchTime? = nil
    /// True if the animation is playing
    public var isPlaying: Bool {
        return !self.node.isPaused
    }
    /// The proportion of progress through the model's animation, in the range [0, 1]
    public var animationProgressProportion: Double {
        return self.animationProgress/self.animationDuration
    }
    
    // MARK: - Constructors
    
    init(dir: String = "Models.scnassets", fileName: String) {
        if let scene = SCNScene(named: "\(dir)/\(fileName)"){
            for childNode in scene.rootNode.childNodes {
                self.node.addChildNode(childNode)
            }
        } else {
            assertionFailure("File '\(fileName)' could not be loaded from \(dir)")
        }
        self.node.name = "\(Self.NAME_PREFIX)-\(fileName)"
        
        for node in NodeUtil.getHierarchy(for: self.node) {
            for key in node.animationKeys {
                if let animationPlayer = node.animationPlayer(forKey: key) {
                    self.animationPlayers.append(animationPlayer)
                }
            }
        }
        
        self.animationDuration = self.animationPlayers.first?.animation.duration ?? 0.0
        
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            guard self.isPlaying else {
                return
            }
            var addition = 0.0
            if let testTimer = self.timer {
                addition = Double(DispatchTime.now().uptimeNanoseconds - testTimer.uptimeNanoseconds)/1_000_000_000.0
            }
            self.animationProgress = (self.animationProgress + addition*self.animationSpeed)
            if isGreater(self.animationProgress, self.animationDuration) {
                self.setAnimationTime(to: 0.0) // Also resets animation progress
            }
            self.timer = DispatchTime.now()
        }
    }
    
    // MARK: - Methods
    
    func add(to sceneView: SCNView) {
        sceneView.scene?.rootNode.addChildNode(self.node)
    }
    
    func remove() {
        self.node.removeFromParentNode()
    }
    
    func play() {
        self.setModelPause(to: false)
    }
    
    func pause() {
        self.setModelPause(to: true)
    }
    
    func setModelPause(to isPaused: Bool) {
        self.node.isPaused = isPaused
        // Timer shouldn't be timing between pauses
        self.timer = self.isPlaying ? DispatchTime.now() : nil
    }
    
    func setAnimationSpeed(to speed: Double) {
        for player in self.animationPlayers {
            player.speed = speed
        }
        self.animationSpeed = speed
    }
    
    func setAnimationTime(to proportion: Double) {
        assert(isLessOrEqual(proportion, 1.0) && isGreaterOrEqualZero(proportion), "Proportion argument must be in the range [0, 1]")
        for player in self.animationPlayers {
            player.animation.timeOffset = proportion*player.animation.duration
            player.play()
        }
        self.animationProgress = proportion*self.animationDuration
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
