//
//  HandModelSequence.swift
//  Lime
//
//  Created by Andre Pham on 1/9/2023.
//

import Foundation
import SceneKit

class HandModelSequence {
    
    // MARK: - Node Properties
    
    /// The hand model mounted onto the scene
    public let handModel: HandModel
    /// The controller the sequence is mounted to
    private weak var controller: SceneController? = nil
    /// The node mounted onto the scene
    private var node: SCNNode {
        return self.handModel.node
    }
    
    // MARK: - Animation Properties
    
    /// All animated hand models provided, which hold the animation players (ordered)
    private let animationModels: [HandModel]
    /// The progress through the entire sequence (seconds)
    private var totalProgress = 0.0
    /// The timer used to measure time between Timer intervals
    /// Found to be more accurate than using the time interval itself
    private var timer: DispatchTime? = nil
    /// The index of the hand model that is active
    private(set) var activeHandIndex: Int = 0
    /// True if the sequence is paused
    private(set) var isPaused = false
    /// The period of time in which we should use non-blended animations due to the animation being reset
    private var resetPeriod: (Double, Double)? = nil
    /// True if the sequence is playing
    public var isPlaying: Bool {
        return !self.isPaused
    }
    /// The index of what hand model / animation player should be made active
    private var activeIndex: Int? {
        for animationPlayerIndex in self.animationPlayers.indices {
            if self.animationShouldPlay(animationIndex: animationPlayerIndex, ignorePause: true) {
                return animationPlayerIndex
            }
        }
        return nil
    }
    /// All animation players from hand models (ordered)
    private var animationPlayers: [SCNAnimationPlayer] {
        return self.animationModels.map({ $0.animationPlayer })
    }
    /// The entire sequence's duration (seconds)
    private var totalDuration: Double {
        return self.animationModels.dropLast().reduce(0.0) {
            $0 + $1.animationDurationBlended
        } + (self.animationModels.last?.animationDuration ?? 0.0)
    }
    /// The speed multiplier on every model's animation
    public var animationSpeed: Double {
        return self.animationPlayers.first!.speed
    }
    /// The proportion of progress through the the entire sequence's animation, in the range [0, 1]
    public var progressProportion: Double {
        return self.totalProgress/self.totalDuration
    }
    
    /// Constructor.
    /// - Parameters:
    ///   - handModel: The hand model to be placed in the scene
    ///   - animationModels: The models which hold the animations to be applied to the hand model
    init(handModel: HandModel, animationModels: [HandModel]) {
        self.handModel = handModel
        self.animationModels = animationModels
        
        // Setup the hand model / node
        self.node.isPaused = true
        self.node.removeAllAnimations()
        for (index, animationPlayer) in self.animationPlayers.enumerated() {
            self.handModel.addAnimation(animationPlayer: animationPlayer, key: "\(index)")
            animationPlayer.paused = true
        }
        
        // Continuously tick - this is what tracks the passage of time, and progresses the animation
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            guard self.isPlaying, let timer = self.timer else {
                self.timer = DispatchTime.now()
                return
            }
            let addition = Double(DispatchTime.now().uptimeNanoseconds - timer.uptimeNanoseconds)/1_000_000_000.0
            self.timer = DispatchTime.now()
            self.totalProgress += addition*self.animationSpeed
            
            if !self.inResetPeriod() {
                self.resetPeriod = nil
            }
            
            if isGreater(self.totalProgress, self.totalDuration) {
                // If the sequence is complete, restart the loop
                self.setSequencePause(to: true)
                self.animationPlayers.forEach({
                    $0.stop()
                })
                self.totalProgress = 0.0
                self.setSequencePause(to: false, noBlend: true)
            }
            
            // Grab the next animation that should be playing right now (if there is one) and play it
            if let animationPlayerThatShouldPlay = self.getAnimationThatShouldPlay() {
                self.getHandModelThatShouldPlay()?.setBlendInDuration()
                self.activeHandIndex = self.activeIndex ?? self.activeHandIndex
                animationPlayerThatShouldPlay.play()
            }
        }
        
        // By default the sequence is paused
        self.setSequencePause(to: true)
    }
    
    func mount(to controller: SceneController?) {
        self.controller = controller
        self.controller?.addModel(self.handModel)
    }
    
    func unmount() {
        self.controller?.removeModel(self.handModel)
        self.controller = nil
    }
    
    /// Clamp the animation's progress to the closest animation start.
    /// - Parameters:
    ///   - progressProportion: The progress proportion to be clamped
    /// - Returns: The progress proportion clamped to
    func clampToClosestAnimation(progressProportion: Double) -> Double {
        let progressProportion = max(0.0, min(1.0, progressProportion))
        for animationIndex in self.animationPlayers.indices {
            let (startTime, endTime) = self.animationStartEndTimes(animationIndex: animationIndex)
            let startProportion = startTime/self.totalDuration
            let endProportion = endTime/self.totalDuration
            var midProportion = (startProportion + endProportion)/2.0
            if animationIndex == self.animationPlayers.endIndex - 1 {
                // If we're at the end animation, we're more biased towards clamping to the second last point
                midProportion = startProportion + (endProportion - startProportion)*0.9
            }
            if isGreaterOrEqual(progressProportion, startProportion) && isLessOrEqual(progressProportion, midProportion) {
                self.setTotalProgressTo(progress: startTime)
                self.activeHandIndex = animationIndex
                return startProportion
            }
            if isGreater(progressProportion, midProportion) && isLess(progressProportion, endProportion) {
                self.setTotalProgressTo(progress: endTime)
                self.activeHandIndex = (animationIndex + 1)%self.animationPlayers.count
                return endProportion
            }
        }
        self.setTotalProgressTo(progress: self.totalDuration)
        self.activeHandIndex = self.animationPlayers.endIndex - 1
        return 1.0
    }
    
    /// Clamp the animation's progress to the current animation's start.
    /// - Parameters:
    ///   - progressProportion: The progress proportion to be clamped
    /// - Returns: The progress proportion clamped to
    func clampToAnimationStart(progressProportion: Double) -> Double {
        let progressProportion = max(0.0, min(1.0, progressProportion))
        for animationIndex in self.animationPlayers.indices {
            let (startTime, endTime) = self.animationStartEndTimes(animationIndex: animationIndex)
            let startProportion = startTime/self.totalDuration
            let endProportion = endTime/self.totalDuration
            if isGreaterOrEqual(progressProportion, startProportion) && isLess(progressProportion, endProportion) {
                self.setTotalProgressTo(progress: startTime)
                self.activeHandIndex = animationIndex
                return startProportion
            }
        }
        let animationIndex = self.animationPlayers.endIndex - 1
        let (startTime, _) = self.animationStartEndTimes(animationIndex: animationIndex)
        let startProportion = startTime/self.totalDuration
        self.setTotalProgressTo(progress: startTime)
        self.activeHandIndex = self.animationPlayers.endIndex - 1
        return startProportion
    }
    
    private func setTotalProgressTo(progress: Double) {
        self.animationPlayers.forEach({
            $0.stop()
        })
        self.totalProgress = progress
        // TODO: What's going on here?
        if isGreaterOrEqual(progress, 1.0) {
            // The hand model is at its non-animated default state because we've reached the end
            // Hide it, and we'll reveal it again when we play
            // (This may be up to the controller)
            self.handModel.setOpacity(to: 0.0)
        }
    }
    
    private func animationStartEndTimes(animationIndex: Int) -> (Double, Double) {
        var priorAnimationDurations = 0.0
        for index in 0..<animationIndex {
            priorAnimationDurations += self.animationModels[index].animationDurationBlended
        }
        return (
            priorAnimationDurations,
            priorAnimationDurations + (
                animationIndex == self.animationModels.endIndex - 1 
                    ?
                self.animationModels[animationIndex].animationDuration 
                    :
                self.animationModels[animationIndex].animationDurationBlended
            )
        )
    }
    
    private func animationShouldPlay(animationIndex: Int, ignorePause: Bool = false) -> Bool {
        if !ignorePause && self.isPaused {
            return false
        }
        let (startTime, endTime) = self.animationStartEndTimes(animationIndex: animationIndex)
        let animationPlayer = self.animationPlayers[animationIndex]
        return isGreaterOrEqual(self.totalProgress, startTime) && isLess(self.totalProgress, endTime) && animationPlayer.paused
    }
    
    private func getAnimationThatShouldPlay(ignorePause: Bool = false) -> SCNAnimationPlayer? {
        for animationPlayerIndex in self.animationPlayers.indices {
            if self.animationShouldPlay(animationIndex: animationPlayerIndex, ignorePause: ignorePause) {
                return self.animationPlayers[animationPlayerIndex]
            }
        }
        return nil
    }
    
    private func getHandModelThatShouldPlay(ignorePause: Bool = false) -> HandModel? {
        for animationPlayerIndex in self.animationPlayers.indices {
            if self.animationShouldPlay(animationIndex: animationPlayerIndex, ignorePause: ignorePause) {
                return self.animationModels[animationPlayerIndex]
            }
        }
        return nil
    }
    
    func setAnimationSpeed(to speed: Double) {
        self.animationPlayers.forEach({ $0.speed = speed })
    }
    
    /// Pause the sequence.
    /// - Parameters:
    ///   - isPaused: True if the sequence should be paused
    ///   - noBlend: True if the sequence should not blend the animation upon resuming
    func setSequencePause(to isPaused: Bool, noBlend: Bool = false) {
        self.isPaused = isPaused
        self.getHandModelThatShouldPlay()?.setBlendInDuration(to: noBlend ? 0.0 : nil)
        if isPaused {
            self.animationPlayers.forEach({ $0.paused = true })
        } else {
            self.handModel.setOpacity(to: 1.0)
            self.activeHandIndex = self.activeIndex ?? self.activeHandIndex
            self.getAnimationThatShouldPlay()?.play()
        }
        self.timer = self.isPlaying ? DispatchTime.now() : nil
    }
    
    /// Pause the sequence. Automatically handles blending based on position.
    /// - Parameters:
    ///   - isPaused: True if the sequence should be paused
    func setSequencePauseAuto(to isPaused: Bool) {
        guard !self.animationModels.isEmpty else {
            return
        }
        let (_, firstTransitionTime) = self.animationStartEndTimes(animationIndex: 0)
        // If we're at the start of the animation or we're in a reset period, don't blend
        self.setSequencePause(
            to: isPaused,
            noBlend: isLess(self.totalProgress, firstTransitionTime) || self.inResetPeriod()
        )
    }
    
    private func inResetPeriod() -> Bool {
        guard let resetPeriod else {
            return false
        }
        return isGreaterOrEqual(self.totalProgress, resetPeriod.0) && isLessOrEqual(self.totalProgress, resetPeriod.1)
    }
    
    func markAsReset() {
        self.resetPeriod = self.transitionStartEndTimes(animationIndex: self.activeHandIndex)
    }
    
    private func transitionStartEndTimes(animationIndex: Int) -> (Double, Double) {
        var priorAnimationDurations = 0.0
        for index in 0..<animationIndex {
            priorAnimationDurations += self.animationModels[index].animationDurationBlended
        }
        return (priorAnimationDurations, priorAnimationDurations + self.animationModels[animationIndex].defaultBlendInDuration)
    }
    
}
