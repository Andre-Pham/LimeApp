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
    
    private let sceneModels: [SceneModel]
    private var activeModelIndex = 0
    public var activeModel: SceneModel {
        return self.sceneModels[self.activeModelIndex]
    }
    private var previousModel: SceneModel {
        let previousIndex = self.activeModelIndex - 1
        return previousIndex < 0 ? self.sceneModels.last! : self.sceneModels[previousIndex]
    }
    private var nextModel: SceneModel {
        let nextIndex = (self.activeModelIndex + 1)%self.sceneModels.count
        return self.sceneModels[nextIndex]
    }
    private weak var controller: SceneController? = nil
    private var transitionStyle: TransitionStyle = .sequential
    
    private var idleStart: Double {
        return self.activeModel.animationDuration - 3.3 //2.8
    }
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
    
    func setSequencePause(to isPaused: Bool) {
        self.activeModel.setModelPause(to: isPaused)
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
        return // TODO: Implement below later
        if isGreaterOrEqual(progress, self.idleStart) && !self.isIdle {
            self.isIdle = true
            print("REAL ENDING HERE")
//            self.onActiveAnimationCompletion()
            self.activeModel.pause()
            self.controller?.addModel(self.nextModel)
            self.nextModel.play()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.nextModel.pause()
                self.activeModel.match(self.nextModel)
            }
        }
    }
    
}
