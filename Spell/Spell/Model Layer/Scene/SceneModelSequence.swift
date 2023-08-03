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
    
    func playSequence() {
        self.setSequencePause(to: false)
    }
    
    func pauseSequence() {
        self.setSequencePause(to: true)
    }
    
    func setSequencePause(to isPaused: Bool) {
//        print("-- Setting Sequence Pause --")
        self.activeModel.setModelPause(to: isPaused)
    }
    
    func setSequenceAnimationSpeed(to speed: Double) {
        self.sceneModels.forEach({ $0.setAnimationSpeed(to: speed) })
    }
    
    func setSequenceAnimationMultiplier(to product: Double) {
        self.sceneModels.forEach({ $0.setAnimationMultiplier(to: product) })
    }
    
    // TODO: For all these Self.IDLE_TIME stuff, I should consider the sequential mode
    // I think setting IDLE_PERIOD to 0.0 for sequential mode would solve this
    
    // ALSO:
    // I will now just clamp the progress to the beginning of an animation (and show above the progress bar what you're clamping to)
    // That solves all of this nonsense
    // Also I can re-implement my transaction times stash -
    /*
     nextModel.setOpacity(to: 0.0)
     self.controller?.addModel(nextModel)
     nextModel.play()
     */
    // I use this code below to get the rotation difference so I can use this again
    
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
            print("Not less than")
            let lastSceneModelIndex = self.sceneModels.count - 1
//            self.switchActiveModel(to: lastSceneModelIndex, animationTime: (self.sceneModels[lastSceneModelIndex].animationDuration - Self.IDLE_PERIOD)/self.sceneModels[lastSceneModelIndex].animationDuration)
            let lastSceneModelDuration = self.sceneModels[lastSceneModelIndex].animationDuration
            let endOfLastAnimation = (lastSceneModelDuration - Self.IDLE_PERIOD)/lastSceneModelDuration
            self.switchActiveModel(to: lastSceneModelIndex, animationTime: endOfLastAnimation)
            return
        }
//        print("setAnimationTime")
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
//        print("switchActiveModel")
//        print("SWITCHING FROM \(self.activeModel.name) TO \(self.sceneModels[index].name)")
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
        print(">>>>>>>>>> TRIGGERING")
//        if self.transitionStyle == .interpolated {
//            self.isIdle = false
//            print(self.activeModel.isPlaying)
//            print(self.activeModel.animationProgress)
//            print(self.activeModel.animationProgressProportion)
//            self.activeModel.setAnimationTime(to: self.idleStart)
//            self.onAnimationTick(progress: self.activeModel.animationDuration)
//            return
//        }
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
    
//    private var transitionInterrupted = false
    
    private func onAnimationTick(progress: Double) {
//        print("onAnimationTick: \(progress.rounded(decimalPlaces: 4))s | idle: \(self.isIdle) | idleStart: \(self.idleStart)")
//        print("onAnimationTick \(isGreaterOrEqual(progress, self.idleStart)) && \(!self.isIdle)")
        if isGreaterOrEqual(progress, self.idleStart) && !self.isIdle {
            self.isIdle = true
            guard self.transitionStyle == .interpolated else {
                return
            }
            print(">>> Transitioning from \(self.activeModel.name) to \(self.nextModel.name)")
//            print(">> Setting active model to paused during animation tick")
            self.activeModel.pause()
            let nextModel = self.nextModel.clone()
//            print("onAnimationTick: nextModel.onAnimationStart")
            nextModel.onAnimationStart = {
//                print("onAnimationTick: COMPLETED: nextModel.onAnimationStart")
                nextModel.onAnimationStart = nil // Only trigger once
//                print(">> Setting next model \(nextModel.name) to paused during animation tick")
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
//                self.transitionInterrupted = false // We only care about interruptions during async operations
//                print("onAnimationTick: activeModel.match")
                self.activeModel.match(nextModelRotation, animationDuration: duration) {
//                    print("onAnimationTick: COMPLETED: activeModel.match")
//                    guard !self.transitionInterrupted else {
//                        self.transitionInterrupted = false
//                        return
//                    }
                    self.switchActiveModel(to: (self.activeModelIndex + 1)%self.sceneModels.count)
                    self.controller?.removeModel(nextModel)
                    self.setSequenceAnimationMultiplier(to: 0.8)
//                    let activeModel = self.activeModel
//                    activeModel.setAnimationMultiplier(to: 0.8)
//                    print(">>> Setting multiplier for \(activeModel.name) to 0.8 | speed: \(activeModel.animationSpeed.toString(decimalPlaces: 3)) | active speed: \(self.activeModel.animationSpeed.toString(decimalPlaces: 3)) | active model: \(self.activeModel.name)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
//                        guard !self.transitionInterrupted else {
//                            self.transitionInterrupted = false
//                            return
//                        }
                        self.setSequenceAnimationMultiplier(to: 1.0)
//                        activeModel.setAnimationMultiplier(to: 1.0)
//                        print("<<< Restoring multiplier for \(activeModel.name) to 1.0 | speed: \(activeModel.animationSpeed.toString(decimalPlaces: 3)) | active speed: \(self.activeModel.animationSpeed.toString(decimalPlaces: 3)) | active model: \(self.activeModel.name)")
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
