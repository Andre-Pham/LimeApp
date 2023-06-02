//
//  SceneModelSequence.swift
//  Spell
//
//  Created by Andre Pham on 17/5/2023.
//

import Foundation

class SceneModelSequence {
    
    enum TransitionStyle {
        /// Play each animation one after the other with the same idle pose in between
        case sequential
        /// Play each animation one after the other but transition with linear interpolations
        case interpolated
        /// Begin playing the next animation before the previous has finished using padded frames
        case interlaced
    }
    
    /// The sequence models, in order of play
    private let sceneModels: [SceneModel]
    /// The index of the active model in the sequence
    private var activeModelIndex = 0
    /// The active model in the sequence
    public var activeModel: SceneModel {
        return self.sceneModels[self.activeModelIndex]
    }
    /// The previous model in the sequence
    private var previousModel: SceneModel {
        let previousIndex = self.activeModelIndex - 1
        return previousIndex < 0 ? self.sceneModels.last! : self.sceneModels[previousIndex]
    }
    /// The next model in the sequence
    private var nextModel: SceneModel {
        let nextIndex = (self.activeModelIndex + 1)%self.sceneModels.count
        return self.sceneModels[nextIndex]
    }
    /// The scene that hosts the models
    private weak var controller: SceneController? = nil
    /// How the transition should be handled between signs
    private var transitionStyle: TransitionStyle = .sequential
    /// True if the animation is playing
    public var isPlaying: Bool {
        return self.activeModel.isPlaying
    }
    /// The speed multiplier on every model's animation
    public var animationSpeed: Double {
        // NB: Every model has the same animation speed value
        return self.activeModel.animationSpeed
    }
    /// The entire sequence's duration (seconds)
    public var totalDuration: Double {
        return self.sceneModels.reduce(0.0) { $0 + $1.animationDuration }
    }
    /// The proportion of progress through the the entire sequence's animation, in the range [0, 1]
    public var animationProgressProportion: Double {
        var durationProgress = 0.0
        for index in 0..<self.activeModelIndex {
            durationProgress += self.sceneModels[index].animationDuration
        }
        durationProgress += self.activeModel.animationProgress
        return durationProgress/self.totalDuration
    }
    /// The progress (s) at which the active model becomes idle
    private var idleStart: Double {
        return self.activeModel.animationDuration - 0.8 //2.8
    }
    /// If the current animation playing is idle
    private var isIdle = false
    
    init(_ sceneModels: [SceneModel]) {
        assert(!sceneModels.isEmpty, "Scene model sequence must be provided with at least one model")
        self.sceneModels = sceneModels
        self.activeModel.onAnimationCompletion = self.onActiveAnimationCompletion
        self.activeModel.onAnimationTick = self.onAnimationTick
    }
    
    func mount(to controller: SceneController?) {
        self.controller = controller
        self.controller?.addModel(self.activeModel)
    }
    
    func playSequence() {
        self.setSequencePause(to: false)
    }
    
    func pauseSequence() {
        self.setSequencePause(to: true)
    }
    
    func setSequencePause(to isPaused: Bool) {
        self.activeModel.setModelPause(to: isPaused)
    }
    
    func setSequenceAnimationSpeed(to speed: Double) {
        self.sceneModels.forEach({ $0.setAnimationSpeed(to: speed) })
    }
    
    func setAnimationTime(to proportion: Double) {
        var relativeModelProportions = [Double]()
        for sceneModel in self.sceneModels {
            relativeModelProportions.append(sceneModel.animationDuration/self.totalDuration)
        }
        assert(isEqual(relativeModelProportions.reduce(0.0, +), 1.0), "The sum of the relative proportions of each model should be equal to 1")
        var proportionMeasure = proportion
        for index in 0..<relativeModelProportions.count {
            if isLessZero(proportionMeasure - relativeModelProportions[index]) {
                self.switchActiveModel(
                    to: index,
                    animationTime: proportionMeasure/relativeModelProportions[index]
                )
                return
            } else {
                proportionMeasure -= relativeModelProportions[index]
            }
            
            if isLessZero(proportionMeasure) {
                self.switchActiveModel(
                    to: index,
                    animationTime: relativeModelProportions[index] + proportionMeasure
                )
                return
            }
        }
        assertionFailure("Shouldn't be reachable")
    }
    
    private func switchActiveModel(to index: Int, animationTime: Double? = nil) {
        assert(index < self.sceneModels.count, "Invalid model index provided")
        self.activeModel.pause()
        self.activeModel.setAnimationTime(to: 0.0)
        self.activeModel.onAnimationCompletion = nil
        self.activeModel.onAnimationTick = nil
        self.controller?.removeModel(self.activeModel)
        self.activeModelIndex = index
        self.controller?.addModel(self.activeModel)
        self.activeModel.play()
        self.activeModel.onAnimationCompletion = self.onActiveAnimationCompletion
        self.activeModel.onAnimationTick = self.onAnimationTick
        if let animationTime {
            self.activeModel.setAnimationTime(to: animationTime)
        }
        self.isIdle = isGreaterOrEqual(self.activeModel.animationProgress, self.idleStart)
    }
    
    private func onActiveAnimationCompletion() {
        print("COMPLETED: \(self.activeModel.name)")
        self.activeModel.pause()
        self.activeModel.setAnimationTime(to: 0.0)
        self.activeModel.onAnimationCompletion = nil
        self.activeModel.onAnimationTick = nil
        self.controller?.removeModel(self.activeModel)
        self.activeModelIndex = (self.activeModelIndex + 1)%self.sceneModels.count
        self.controller?.addModel(self.activeModel)
        self.activeModel.play()
        self.activeModel.onAnimationCompletion = self.onActiveAnimationCompletion
        self.activeModel.onAnimationTick = self.onAnimationTick
        self.isIdle = false
        print("STARTING: \(self.activeModel.name)")
    }
    
    private func onAnimationTick(progress: Double) {
        if isGreaterOrEqual(progress, self.idleStart) && !self.isIdle {
            self.isIdle = true
            self.activeModel.pause()
            
            let nextModel = self.nextModel.clone()
            nextModel.onAnimationStart = {
                nextModel.onAnimationStart = nil // Only trigger once
                nextModel.pause()
                self.activeModel.match(nextModel, animationDuration: 0.8)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.switchActiveModel(to: (self.activeModelIndex + 1)%self.sceneModels.count)
                    self.controller?.removeModel(nextModel)
                }
            }
            nextModel.setOpacity(to: 0.0)
            self.controller?.addModel(nextModel)
            nextModel.play()
        }
    }
    
}
