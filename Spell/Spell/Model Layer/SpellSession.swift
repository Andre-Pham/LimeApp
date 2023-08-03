//
//  SpellSession.swift
//  Spell
//
//  Created by Andre Pham on 19/5/2023.
//

import Foundation

class SpellSession {
    
    /// Singleton instance
    public static let inst = SpellSession()
    
    public let sceneViewController: SceneViewController
    private(set) var sequence: SceneModelSequence? = nil
    public var sceneController: SceneController {
        return self.sceneViewController.scene
    }
    
    private init() {
        let sceneController = SceneController()
        self.sceneViewController = SceneViewController()
        self.sceneViewController.attach(scene: sceneController)
        self.sceneViewController.setupScene()
    }
    
    func addSequentialLetterSequence(prompt: String) {
        guard !prompt.isEmpty else {
            self.sequence = nil
            return
        }
        var sceneModels = [SceneModel]()
        for char in prompt {
            sceneModels.append(SceneModel(subDir: "alphabet1", fileName: "\(char)_1.dae", description: char.uppercased()))
        }
        self.sequence = SceneModelSequence(transition: .sequential, sceneModels)
        self.sequence?.mount(to: self.sceneController)
    }
    
    func addInterpolatedLetterSequence(prompt: String) {
        guard !prompt.isEmpty else {
            self.sequence = nil
            return
        }
        var sceneModels = [SceneModel]()
        for char in prompt {
            sceneModels.append(SceneModel(subDir: "alphabet1", fileName: "\(char)_1.dae", description: char.uppercased(), startTrim: 0.2, endTrim: 0.0))
        }
        self.sequence = SceneModelSequence(transition: .interpolated, sceneModels)
        self.sequence?.mount(to: self.sceneController)
    }
    
}
