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
    
    func addLetterSequence(prompt: String) {
        guard !prompt.isEmpty else {
            self.sequence = nil
            return
        }
        var sceneModels = [SceneModel]()
        for char in prompt {
            sceneModels.append(SceneModel(subDir: "alphabet", fileName: "\(char).dae", startTrim: 0.15, endTrim: 2.6))
        }
        self.sequence = SceneModelSequence(sceneModels)
        self.sequence?.mount(to: self.sceneController)
    }
    
}
