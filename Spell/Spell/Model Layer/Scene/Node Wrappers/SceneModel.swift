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
    
    /// All animated nodes used within the model (corresponds to `animationPlayers`)
    private var animatedNodes = [SCNNode]()
    /// All animation players used within the model
    private var animationPlayers = [SCNAnimationPlayer]()
    /// The total length of the animation (seconds)
    public let animationDuration: Double
    /// The progress through the model's animation (seconds)
    private var animationProgress: Double = 0.0
    /// The speed multiplier on the model's animation
    private(set) var animationSpeed = 1.0
    /// The timer used to measure time between Timer intervals
    /// Found to be more accurate than using the time interval itself
    private var timer: DispatchTime? = nil
    /// Callback for when the animation completes
    public var onAnimationCompletion: (() -> Void)? = nil
    /// Callback triggered for every animation tick
    public var onAnimationTick: ((_ progress: Double) -> Void)? = nil
    /// True if the animation is playing
    public var isPlaying: Bool {
        return !self.node.isPaused
    }
    /// The proportion of progress through the model's animation, in the range [0, 1]
    public var animationProgressProportion: Double {
        return self.animationProgress/self.animationDuration
    }
    
    // MARK: - Constructors
    
    init(dir: String = "Models.scnassets", subDir: String? = nil, fileName: String, name: String? = nil) {
        let directory = subDir == nil ? "\(dir)/\(fileName)" : "\(dir)/\(subDir!)/\(fileName)"
        if let scene = SCNScene(named: directory) {
            for childNode in scene.rootNode.childNodes {
                self.node.addChildNode(childNode)
            }
        } else {
            assertionFailure("File '\(fileName)' could not be loaded from \(dir)")
        }
        self.node.name = (name == nil ? "\(Self.NAME_PREFIX)-\(fileName)" : "\(Self.NAME_PREFIX)-\(name!)")
        
        for node in NodeUtil.getHierarchy(for: self.node) {
            var isAnimated = false
            for key in node.animationKeys {
                if let animationPlayer = node.animationPlayer(forKey: key) {
                    self.animationPlayers.append(animationPlayer)
                    isAnimated = true
                }
            }
            if isAnimated {
                self.animatedNodes.append(node)
            }
        }
        
        self.animationDuration = self.animationPlayers.first?.animation.duration ?? 0.0
        
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            guard self.isPlaying, let timer = self.timer else {
                self.timer = DispatchTime.now()
                return
            }
            let addition = Double(DispatchTime.now().uptimeNanoseconds - timer.uptimeNanoseconds)/1_000_000_000.0
            self.animationProgress = (self.animationProgress + addition*self.animationSpeed)
            self.onAnimationTick?(self.animationProgress)
            // TODO: Should this be isGreater or isGreaterOrEqual ?
            if isGreater(self.animationProgress, self.animationDuration) {
                self.onAnimationCompletion?()
                self.setAnimationTime(to: 0.0) // Also resets animation progress
            }
            self.timer = DispatchTime.now()
        }
        
        self.pause()
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
        for player in self.animationPlayers {
            if isPaused {
                player.paused = true
            } else {
                player.play()
            }
        }
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
    
    func match(_ model: SceneModel, animationDuration: Double? = nil) {
        // Obviously inefficient, will review later
        for node in NodeUtil.getHierarchy(for: self.node) {
            for otherNode in NodeUtil.getHierarchy(for: model.node) {
                if node.name == otherNode.name {
                    if node.presentation.rotation != otherNode.presentation.rotation {
                        let targetRotation = otherNode.presentation.rotation

                        SCNTransaction.begin()
                        SCNTransaction.animationDuration = 1.0 // replace with desired animation duration

                        // Set the node's rotation within the transaction
                        node.rotation = targetRotation

                        SCNTransaction.commit()
                    }
                }
            }
        }
    }
    
}
