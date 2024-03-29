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
        /// Begin playing the next animation before the previous has finished using padded frames (play both animations at once)
        //case interlaced // CURRENTLY NOT SUPPORTED
    }
    
    /// Each model animation has a period at the end where it holds an "idle pose" - this defines the length of that period
    /// Animation transitions between models begin at the start of the idle period
    private static let IDLE_PERIOD = 0.45
    
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
    private var transitionStyle: TransitionStyle
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
        return self.sceneModels.reduce(0.0) { $0 + $1.animationDuration - Self.IDLE_PERIOD }
    }
    /// The proportion of progress through the the entire sequence's animation, in the range [0, 1]
    public var animationProgressProportion: Double {
        var durationProgress = 0.0
        for index in 0..<self.activeModelIndex {
            durationProgress += self.sceneModels[index].animationDuration - Self.IDLE_PERIOD
        }
        durationProgress += self.activeModel.animationProgress
        return durationProgress/self.totalDuration
    }
    /// The progress (seconds) at which the active model becomes idle
    private var idleStart: Double {
        return self.activeModel.animationDuration - Self.IDLE_PERIOD
    }
    /// If the current animation playing is idle
    private var isIdle = false
    /// If the sequence is transitioning (via interpolation) between two scene models
    private var isTransitioning = false
    
    init(transition: TransitionStyle, _ sceneModels: [SceneModel]) {
        self.transitionStyle = transition
        assert(!sceneModels.isEmpty, "Scene model sequence must be provided with at least one model")
        self.sceneModels = sceneModels
        self.activeModel.onAnimationCompletion = self.onActiveAnimationCompletion
        self.activeModel.onAnimationTick = self.onAnimationTick
    }
    
    func mount(to controller: SceneController?) {
        self.controller = controller
        self.controller?.addModel(self.activeModel)
    }
    
    func unmount() {
        for model in self.sceneModels {
            self.controller?.removeModel(model)
        }
        self.controller = nil
    }
    
    func playSequence() {
        self.setSequencePause(to: false)
    }
    
    func pauseSequence() {
        self.setSequencePause(to: true)
    }
    
    func interruptTransition() {
        self.isTransitioning = false
        // Technically unnecessary, this just ensures we're at the correct animation multiplier (immediately)
        self.setSequenceAnimationMultiplier(to: 1.0)
    }
    
    func setSequencePause(to isPaused: Bool) {
        if self.isTransitioning && isPaused {
            // We're trying to pause during a transition, so clamp to the start of the model we're transitioning to
            //
            // The following code is strange...
            // A working alternative is as follows:
            // ``` self.isTransitioning = false
            //     self.switchActiveModel(to: (self.activeModelIndex + 1)%self.sceneModels.count)
            // ```
            // However it causes a flicker that isn't pleasant to the eye
            // This odd sequence of timings fix that
            // All timings are magic numbers, and the smallest interval that worked that I've tried is 0.02
            self.interruptTransition()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                self.switchActiveModel(to: (self.activeModelIndex + 1)%self.sceneModels.count)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                self.activeModel.setModelPause(to: true)
            }
        } else {
            self.activeModel.setModelPause(to: isPaused)
        }
    }
    
    func setSequenceAnimationSpeed(to speed: Double) {
        self.sceneModels.forEach({ $0.setAnimationSpeed(to: speed) })
    }
    
    func setSequenceAnimationMultiplier(to product: Double) {
        self.sceneModels.forEach({ $0.setAnimationMultiplier(to: product) })
    }
    
    // TODO: For all these Self.IDLE_TIME stuff, I should consider the sequential mode
    // I think setting IDLE_PERIOD to 0.0 for sequential mode would solve this
    
    // TODO: Remove transition (which is already buggy) between last model and starting model
    
    @discardableResult
    func clampToAnimationStart(proportion: Double) -> Double {
        var relativeModelProportions = [Double]()
        for sceneModel in self.sceneModels {
            relativeModelProportions.append((sceneModel.animationDuration - Self.IDLE_PERIOD)/self.totalDuration)
        }
        assert(isEqual(relativeModelProportions.reduce(0.0, +), 1.0), "The sum of the relative proportions of each model should be equal to 1")
        var intervals: [Double] = [0.0]
        var sum = 0.0
        for modelProportion in relativeModelProportions {
            sum += modelProportion
            intervals.append(sum)
        }
        let animationTime = intervals.closest(to: proportion)! // Array is never empty - force unwrap
        self.setAnimationTime(to: animationTime)
        return animationTime
    }
    
    func setAnimationTime(to proportion: Double) {
        guard isLess(proportion, 1.0) else {
            let lastSceneModelIndex = self.sceneModels.count - 1
            let lastSceneModelDuration = self.sceneModels[lastSceneModelIndex].animationDuration
            let endOfLastAnimation = (lastSceneModelDuration - Self.IDLE_PERIOD)/lastSceneModelDuration
            self.switchActiveModel(to: lastSceneModelIndex, animationTime: endOfLastAnimation)
            return
        }
        var relativeModelProportions = [Double]()
        for sceneModel in self.sceneModels {
            relativeModelProportions.append((sceneModel.animationDuration - Self.IDLE_PERIOD)/self.totalDuration)
        }
        assert(isEqual(relativeModelProportions.reduce(0.0, +), 1.0), "The sum of the relative proportions of each model should be equal to 1")
        var proportionMeasure = proportion
        for index in 0..<relativeModelProportions.count {
            if isLessZero(proportionMeasure - relativeModelProportions[index]) {
                // We are within the animation's portion of the full sequence
                self.switchActiveModel(
                    to: index,
                    animationTime: proportionMeasure/relativeModelProportions[index]
                )
                return
            } else {
                // Subtract this animation's portion from the proportion
                // (As if that part of the proportion and that animation never existed in the sequence)
                proportionMeasure -= relativeModelProportions[index]
            }
            
            if isLessZero(proportionMeasure) {
                // If we're (virtually) at the end of the animation
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
        self.activeModel.onAnimationCompletion = self.onActiveAnimationCompletion
        self.activeModel.onAnimationTick = self.onAnimationTick
        self.activeModel.play()
        if let animationTime {
            self.activeModel.setAnimationTime(to: animationTime)
        }
        self.isIdle = isGreaterOrEqual(self.activeModel.animationProgress, self.idleStart)
    }
    
    private func onActiveAnimationCompletion() {
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
    }
    
    private func onAnimationTick(progress: Double) {
        if isGreaterOrEqual(progress, self.idleStart) && !self.isIdle {
            self.isIdle = true
            guard self.transitionStyle == .interpolated else {
                return
            }
            self.activeModel.pause()
            let nextModel = self.nextModel.clone()
            nextModel.onAnimationStart = {
                nextModel.onAnimationStart = nil // Only trigger once
                nextModel.pause()
                // TODO: Define timings with functions and constants
                let activeModelRotation = self.activeModel.getRotationsIndex()
                let nextModelRotation = nextModel.getRotationsIndex()
                let rotationMagnitude = activeModelRotation.getHandRotation(relativeTo: nextModelRotation)
                // All these numbers are magic
                var duration = Double(rotationMagnitude/5.0)
                if isGreater(duration, 0.65) {
                    duration = 0.6 + (duration - 0.6)/5
                } else if isLess(duration, 0.2) {
                    duration = 0.2 - (0.2 - duration)/2
                }
                duration /= self.animationSpeed
                self.isTransitioning = true
                self.activeModel.match(nextModelRotation, animationDuration: duration) {
                    guard self.isTransitioning else {
                        self.controller?.removeModel(nextModel)
                        return
                    }
                    self.isTransitioning = false
                    self.switchActiveModel(to: (self.activeModelIndex + 1)%self.sceneModels.count)
                    self.controller?.removeModel(nextModel)
                    self.setSequenceAnimationMultiplier(to: 0.8)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        self.setSequenceAnimationMultiplier(to: 1.0)
                    }
                }
            }
            // The model has to be in a scene to have its animation rotations rendered
            // Add it to the scene and make its opacity 0 so it can't be seen
            nextModel.setOpacity(to: 0.0)
            self.controller?.addModel(nextModel)
            nextModel.play()
        }
    }
    
}
