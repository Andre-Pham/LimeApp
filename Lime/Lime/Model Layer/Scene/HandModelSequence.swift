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
    
    /// All hand models provided, which hold the animation players (ordered)
    private let handModels: [HandModel]
    /// The progress through the entire sequence (seconds)
    private var totalProgress = 0.0
    /// The timer used to measure time between Timer intervals
    /// Found to be more accurate than using the time interval itself
    private var timer: DispatchTime? = nil
    /// The index of the hand model that is active
    private(set) var activeHandIndex: Int = 0
    /// True if the sequence is paused
    private var isPaused = false
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
        return self.handModels.map({ $0.animationPlayer })
    }
    /// The entire sequence's duration (seconds)
    private var totalDuration: Double {
        return self.handModels.dropLast().reduce(0.0) {
            $0 + $1.animationDurationBlended
        } + (self.handModels.last?.animationDuration ?? 0.0)
    }
    /// The speed multiplier on every model's animation
    public var animationSpeed: Double {
        return self.animationPlayers.first!.speed
    }
    /// The proportion of progress through the the entire sequence's animation, in the range [0, 1]
    public var progressProportion: Double {
        return self.totalProgress/self.totalDuration
    }
    
    init(handModels: [HandModel]) {
        self.handModels = handModels
        
        self.handModel = self.handModels.first!
        self.node.isPaused = true
        self.node.removeAllAnimations()
        for (index, animationPlayer) in self.animationPlayers.enumerated() {
            self.handModel.addAnimation(animationPlayer: animationPlayer, key: "\(index)")
            animationPlayer.paused = true
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            guard self.isPlaying, let timer = self.timer else {
                self.timer = DispatchTime.now()
                return
            }
            let addition = Double(DispatchTime.now().uptimeNanoseconds - timer.uptimeNanoseconds)/1_000_000_000.0
            self.totalProgress += addition*self.animationSpeed
            
            if isGreater(self.totalProgress, self.totalDuration) {
                print("> set total progress to 0.0")
//                self.setTotalProgressTo(progress: 0.0)
                
                self.setSequencePause(to: true)
                self.animationPlayers.forEach({
                    $0.stop()
                })
                self.totalProgress = 0.0
                self.setSequencePause(to: false, noBlend: true)
            }
            
            if let animationPlayerThatShouldPlay = self.getAnimationThatShouldPlay() {
                self.getHandModelThatShouldPlay()?.setBlendInDuration()
                self.activeHandIndex = self.activeIndex ?? self.activeHandIndex
                print("> playing \(self.activeIndex ?? -1) blend: \(self.animationPlayers[self.activeIndex ?? 0].animation.blendInDuration) paused: \(self.animationPlayers[self.activeIndex ?? 0].paused)")
                animationPlayerThatShouldPlay.play()
            }
            
            self.timer = DispatchTime.now()
        }
        
        self.setSequencePause(to: true)
        
        
//        for i in 0..<4 {
//            print(self.animationStartEndTimes(animationIndex: i))
//        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.setSequencePause(to: false, noBlend: true)
//        }
        
//        self.setSequencePause(to: false, noBlend: true)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            self.setSequencePause(to: true)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                self.setTotalProgressTo(progress: 0.9333330154418945)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                    self.setSequencePause(to: false)
//                }
//            }
//        }
        
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            self.setSequencePause(to: true)
//            self.animationPlayers.forEach({ $0.stop() })
//            self.totalProgress = 0.9333330154418945
//
//
//
//            self.setSequencePause(to: false, noBlend: true)
//
//        }
        
        
//        self.setAnimationSpeed(to: 0.5)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.setSequencePause(to: true)
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            self.setSequencePause(to: false)
//        }
    }
    
    func mount(to controller: SceneController?) {
        self.controller = controller
        self.controller?.addModel(self.handModel)
    }
    
    func unmount() {
        self.controller?.removeModel(self.handModel)
        self.controller = nil
    }
    
    func clampToAnimationStart(progressProportion: Double) -> Double {
        let progressProportion = max(0.0, min(1.0, progressProportion))
        for animationIndex in self.animationPlayers.indices {
            let (startTime, endTime) = self.animationStartEndTimes(animationIndex: animationIndex)
            let startProportion = startTime/self.totalDuration
            let endProportion = endTime/self.totalDuration
            var midProportion = (startProportion + endProportion)/2.0
            if animationIndex == self.animationPlayers.endIndex - 1 {
                // If we're at the end animation, we're more biased towards clamping to the second last point
                midProportion = startProportion + (endProportion - startProportion)*0.75
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
    
    private func setTotalProgressTo(progress: Double) {
//        let wasPaused = self.isPaused
//        self.setSequencePause(to: true)
////        self.animationPlayers.forEach({ $0.stop() })
//        self.totalProgress = progress
//        self.setSequencePause(to: wasPaused, noBlend: true)
        
//        let wasPaused = self.isPaused
        
//        self.setSequencePause(to: true)
        self.animationPlayers.forEach({
            $0.stop()
        })
        self.totalProgress = progress
        if isGreaterOrEqual(progress, 1.0) {
            print("OPACITY TO 0.0")
            self.handModel.setOpacity(to: 0.0)
        }
//        self.setSequencePause(to: wasPaused, noBlend: true)
    }
    
    private func animationStartEndTimes(animationIndex: Int) -> (Double, Double) {
        var priorAnimationDurations = 0.0
        for index in 0..<animationIndex {
            priorAnimationDurations += self.handModels[index].animationDurationBlended
        }
        return (priorAnimationDurations, priorAnimationDurations + (animationIndex == self.handModels.endIndex - 1 ? self.handModels[animationIndex].animationDuration : self.handModels[animationIndex].animationDurationBlended))
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
                return self.handModels[animationPlayerIndex]
            }
        }
        return nil
    }
    
    func setAnimationSpeed(to speed: Double) {
        self.animationPlayers.forEach({ $0.speed = speed })
    }
    
    func setSequencePause(to isPaused: Bool, noBlend: Bool = false) {
        self.isPaused = isPaused
        print("set pause status to: \(isPaused)")
        self.getHandModelThatShouldPlay()?.setBlendInDuration(to: noBlend ? 0.0 : nil)
        if isPaused {
            self.animationPlayers.forEach({ $0.paused = true })
//            if isGreaterOrEqual(self.animationProgressProportion, 1.0) {
//                self.handModel.setOpacity(to: 0.0)
//            }
        } else {
            print("OPACITY TO 1.0")
            self.handModel.setOpacity(to: 1.0)
            print(">> playing \(self.activeIndex ?? -1) blend: \(self.animationPlayers[self.activeIndex ?? 0].animation.blendInDuration) paused: \(self.animationPlayers[self.activeIndex ?? 0].paused)")
//            self.handModel.setOpacity(to: 1.0)
            self.activeHandIndex = self.activeIndex ?? self.activeHandIndex
            self.getAnimationThatShouldPlay()?.play()
        }
        self.timer = self.isPlaying ? DispatchTime.now() : nil
    }
    
}
