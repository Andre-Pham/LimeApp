//
//  SceneModelSequenceBlend.swift
//  Lime
//
//  Created by Andre Pham on 1/9/2023.
//

import Foundation
import SceneKit

class SceneModelSequenceBlend {
    
    // MARK: - Constants
    
    public static let NAME_PREFIX = "model"
    
    // MARK: - Node Properties
    
    public let handModel: HandModel
    private weak var controller: SceneController? = nil
    public var node: SCNNode {
        return self.handModel.node
    }
    
    // MARK: - Animation Properties
    
    private let handModels: [HandModel]
    private var totalProgress = 0.0
    private var timer: DispatchTime? = nil
    private(set) var lastPlayedIndex: Int = 0
    private var isPaused = false
    public var isPlaying: Bool {
        return !self.isPaused
    }
    public var animationProgressProportion: Double {
        return self.totalProgress/self.totalDurationWithBlend
    }
    private var activeIndex: Int? {
        for animationPlayerIndex in self.animationPlayers.indices {
            if self.animationShouldPlay(animationIndex: animationPlayerIndex, ignorePause: true) {
                return animationPlayerIndex
            }
        }
        return nil
    }
    private var animationPlayers: [SCNAnimationPlayer] {
        return self.handModels.map({ $0.animationPlayer })
    }
    private var totalDuration: Double {
        return self.handModels.reduce(0.0) {
            $0 + $1.animationDuration
        }
    }
    private var totalDurationWithBlend: Double {
        return self.handModels.dropLast().reduce(0.0) {
            $0 + $1.animationDurationBlended
        } + (self.handModels.last?.animationDuration ?? 0.0)
    }
    private var animationSpeed: Double {
        return self.animationPlayers.first!.speed
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
            
            if isGreater(self.totalProgress, self.totalDurationWithBlend) {
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
                self.lastPlayedIndex = self.activeIndex ?? self.lastPlayedIndex
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
    
    private func setTotalProgressTo(progress: Double) {
        let wasPaused = self.isPaused
        self.setSequencePause(to: true)
//        self.animationPlayers.forEach({ $0.stop() })
        self.totalProgress = progress
        self.setSequencePause(to: wasPaused, noBlend: true)
    }
    
    private func animationStartEndTimes(animationIndex: Int) -> (Double, Double) {
        var priorAnimationDurations = 0.0
        for index in 0..<animationIndex {
            priorAnimationDurations += self.handModels[index].animationDurationBlended
        }
        return (priorAnimationDurations, priorAnimationDurations + (animationIndex == self.handModels.endIndex ? self.handModels[animationIndex].animationDuration : self.handModels[animationIndex].animationDurationBlended))
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
        } else {
            print(">> playing \(self.activeIndex ?? -1) blend: \(self.animationPlayers[self.activeIndex ?? 0].animation.blendInDuration) paused: \(self.animationPlayers[self.activeIndex ?? 0].paused)")
            self.lastPlayedIndex = self.activeIndex ?? self.lastPlayedIndex
            self.getAnimationThatShouldPlay()?.play()
        }
        self.timer = self.isPlaying ? DispatchTime.now() : nil
    }
    
}
