//
//  SceneModel.swift
//  Lime
//
//  Created by Andre Pham on 9/4/2023.
//

import Foundation
import SceneKit

class SceneModel: Clonable {
    
    // MARK: - Constants
    
    public static let NAME_PREFIX = "model"
    
    // MARK: - Node Properties
    
    private var node: SCNNode = SCNNode()
    private var setDescription: String? = nil
    public var description: String {
        return self.setDescription ?? self.name
    }
    public var name: String {
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
    private(set) var animationProgress: Double = 0.0
    /// The multiplier used when setting the animation speed
    private(set) var animationSpeedMultiplier = 1.0
    /// The speed multiplier on the model's animation
    private(set) var animationSpeed = 1.0
    /// The timer used to measure time between Timer intervals
    /// Found to be more accurate than using the time interval itself
    private var timer: DispatchTime? = nil
    /// Callback for when the animation completes
    public var onAnimationCompletion: (() -> Void)? = nil
    /// Callback triggered for every animation tick
    public var onAnimationTick: ((_ progress: Double) -> Void)? = nil
    /// Callback triggered when the animation starts
    public var onAnimationStart: (() -> Void)? = nil {
        didSet {
            self.animationPlayers.first?.animation.animationDidStart = { animation, animatableNode in
                self.onAnimationStart?()
            }
        }
    }
    /// Callback triggered when the animation ends
    public var onAnimationStop: (() -> Void)? = nil {
        didSet {
            self.animationPlayers.first?.animation.animationDidStop = { animation, animatableNode, finished in
                self.onAnimationStop?()
            }
        }
    }
    /// True if the animation is playing
    public var isPlaying: Bool {
        return !self.node.isPaused
    }
    /// The proportion of progress through the model's animation, in the range [0, 1]
    public var animationProgressProportion: Double {
        return self.animationProgress/self.animationDuration
    }
    /// Trim the beginning of the animation (seconds)
    private let startTrim: Double
    /// Trim the end of the animation (seconds)
    private let endTrim: Double
    
    // MARK: - Constructors
    
    init(
        dir: String = "Models.scnassets",
        subDir: String? = nil,
        fileName: String,
        name: String? = nil,
        description: String? = nil,
        startTrim: Double = 0.0,
        endTrim: Double = 0.0
    ) {
        let directory = subDir == nil ? "\(dir)/\(fileName)" : "\(dir)/\(subDir!)/\(fileName)"
        if let scene = SCNScene(named: directory) {
            for childNode in scene.rootNode.childNodes {
                self.node.addChildNode(childNode)
            }
        } else {
            assertionFailure("File '\(fileName)' could not be loaded from \(dir)")
        }
        self.node.name = (name == nil ? "\(Self.NAME_PREFIX)-\(fileName)" : "\(Self.NAME_PREFIX)-\(name!)")
        self.setDescription = description
        
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
        
        self.startTrim = startTrim
        self.endTrim = endTrim
        
        if let totalDuration = self.animationPlayers.first?.animation.duration {
            self.animationDuration = totalDuration - self.endTrim - self.startTrim
        } else {
            self.animationDuration = 0.0
        }
        
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
        
        if isGreater(self.startTrim, 0.0) {
            self.setAnimationTime(to: 0.0)
        }
        self.pause()
    }
    
    required init(_ original: SceneModel) {
        self.node = original.node.clone()
        self.node.name = original.name + "-clone"
        self.setDescription = original.setDescription
        // Can't directly clone the animation players and animated nodes - they need to be attached to this model's root node
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
        self.animationDuration = original.animationDuration
        self.animationProgress = original.animationProgress
        self.animationSpeed = original.animationSpeed
        self.timer = nil
        self.onAnimationCompletion = nil
        self.onAnimationTick = nil
        self.startTrim = original.startTrim
        self.endTrim = original.endTrim
        
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
            player.speed = speed*self.animationSpeedMultiplier
        }
        self.animationSpeed = speed*self.animationSpeedMultiplier
    }
    
    func setAnimationMultiplier(to product: Double) {
        let rawAnimationSpeed = self.animationSpeed/self.animationSpeedMultiplier // Animation speed without multiplier
        self.animationSpeedMultiplier = product
        self.setAnimationSpeed(to: rawAnimationSpeed)
    }
    
    func setAnimationTime(to proportion: Double) {
        assert(isLessOrEqual(proportion, 1.0) && isGreaterOrEqualZero(proportion), "Proportion argument must be in the range [0, 1]")
        for player in self.animationPlayers {
            player.animation.timeOffset = self.startTrim + proportion*player.animation.duration
            player.play()
        }
        self.animationProgress = proportion*self.animationDuration
    }
    
    func getRotationsIndex() -> ModelRotationsIndex {
        let index = ModelRotationsIndex()
        for node in NodeUtil.getHierarchy(for: self.node) {
            if let nodeName = node.name {
                index.addRotation(nodeName: nodeName, rotation: node.presentation.rotation)
            }
        }
        return index
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
    
    func match(_ model: SceneModel, animationDuration: Double = 1.0, onCompletion: @escaping () -> Void) {
        self.match(model.getRotationsIndex(), animationDuration: animationDuration, onCompletion: onCompletion)
    }
    
    func match(_ modelRotationIndex: ModelRotationsIndex, animationDuration: Double = 1.0, onCompletion: @escaping () -> Void) {
        assert(isGreaterZero(animationDuration), "Animation duration must be >= 0.0")
        var remainingTransactions = 0
        for node in NodeUtil.getHierarchy(for: self.node) {
            if let nodeName = node.name,
               let targetRotation = modelRotationIndex.getRotation(nodeName: nodeName),
               node.presentation.rotation != targetRotation {
                remainingTransactions += 1
                SCNTransaction.begin()
                SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
                SCNTransaction.animationDuration = animationDuration

                // Set the node's rotation within the transaction
                node.rotation = targetRotation

                SCNTransaction.completionBlock = {
                    remainingTransactions -= 1
                    if remainingTransactions == 0 {
                        onCompletion()
                    }
                }
                SCNTransaction.commit()
            }
        }
    }
    
    func setOpacity(to opacity: Double) {
        self.node.opacity = opacity
    }
    
}
