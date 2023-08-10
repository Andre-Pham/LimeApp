//
//  LimeSession.swift
//  Lime
//
//  Created by Andre Pham on 19/5/2023.
//

import Foundation
import SceneKit

class LimeSession {
    
    /// Singleton instance
    public static let inst = LimeSession()
    
    public let sceneController = SceneController()
    private(set) var activePrompt: String = ""
    private(set) var sequence: SceneModelSequence? = nil
    
    private init() { }
    
    func setupScene() {
        let camera = SceneCamera()
            .setPosition(to: SCNVector3(x: 0, y: 0, z: 15))
            .setRenderDistance(far: 500.0, near: 0.0)
        self.sceneController.setCamera(to: camera)
        
        let highlights = SceneLight(id: "highlights")
            .setType(to: .omni)
            .setColor(to: LimeColors.accent)
            .setPosition(to: SCNVector3(x: 0, y: 10, z: 2))
            .setIntensity(to: 800)
        self.sceneController.addLight(highlights)
        
        let frontLight = SceneLight(id: "frontLight")
            .setType(to: .directional)
            .setColor(to: LimeColors.accent)
            .setPosition(to: SCNVector3(x: 0, y: 8, z: 10))
            .direct(to: SCNVector3())
        self.sceneController.addLight(frontLight)
        
        let backLight = SceneLight(id: "backLight")
            .setType(to: .directional)
            .setColor(to: LimeColors.accent)
            .setPosition(to: SCNVector3(x: 0, y: 8, z: -10))
            .direct(to: SCNVector3())
        self.sceneController.addLight(backLight)
        
        let ambientLight = SceneLight(id: "ambient")
            .setType(to: .ambient)
            .setColor(to: LimeColors.accent)
            .setIntensity(to: 200)
        self.sceneController.addLight(ambientLight)
        
        self.sceneController.setCameraControl(allowed: true)
        self.sceneController.setBackgroundColor(to: UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1.00))
    }
    
    func addSequentialLetterSequence(prompt: String) -> Bool {
        let prompt = self.cleanPrompt(prompt: prompt)
        guard prompt != self.activePrompt else {
            return false
        }
        self.sequence?.unmount()
        self.activePrompt = prompt
        guard !prompt.isEmpty else {
            self.sequence = nil
            return true
        }
        var sceneModels = [SceneModel]()
        for char in prompt {
            sceneModels.append(SceneModel(subDir: "alphabet1", fileName: "\(char)_1.dae", description: char.uppercased()))
        }
        self.sequence = SceneModelSequence(transition: .sequential, sceneModels)
        self.sequence?.mount(to: self.sceneController)
        return true
    }
    
    func addInterpolatedLetterSequence(prompt: String) -> Bool {
        let prompt = self.cleanPrompt(prompt: prompt)
        guard prompt != self.activePrompt else {
            return false
        }
        self.sequence?.unmount()
        self.activePrompt = prompt
        guard !prompt.isEmpty else {
            self.sequence = nil
            return true
        }
        var sceneModels = [SceneModel]()
        for char in prompt {
            sceneModels.append(SceneModel(subDir: "alphabet1", fileName: "\(char)_1.dae", description: char.uppercased(), startTrim: 0.2, endTrim: 0.0))
        }
        self.sequence = SceneModelSequence(transition: .interpolated, sceneModels)
        self.sequence?.mount(to: self.sceneController)
        return true
    }
    
    private func cleanPrompt(prompt: String) -> String {
        let cleaned = prompt.lowercased().filter({ $0.isLetter })
        return String(cleaned)
    }
    
}
