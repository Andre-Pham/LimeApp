//
//  SceneSession.swift
//  Lime
//
//  Created by Andre Pham on 19/5/2023.
//

import Foundation
import SceneKit

class SceneSession {
    
    /// Singleton instance
    public static let inst = SceneSession()
    
    public let sceneController = SceneController()
    private(set) var activePrompt: String = ""
    private(set) var sequence: HandModelSequence? = nil
    private var animationModelFileDirectory: String {
        return SettingsSession.inst.settings.leftHanded ? "alphabet3" : "alphabet1"
    }
    private var animationFileSuffix: String {
        return SettingsSession.inst.settings.leftHanded ? "_3" : "_1"
    }
    private var handModel: HandModel {
        if SettingsSession.inst.settings.realisticHandModel {
            let result = HandModel(subDir: "realistic", fileName: "idle_realistic_hands.dae", blendInDuration: 0.0)
            result.editMaterial(childNode: .hands) { material in
                material.diffuse.contents = LimeTextures.realisticColor
                material.metalness.contents = LimeTextures.realisticMetalic
                material.roughness.contents = LimeTextures.realisticRoughness
                material.normal.contents = LimeTextures.realisticNormal
                material.lightingModel = .physicallyBased
            }
            return result
        } else {
            return HandModel(subDir: "alphabet1", fileName: "Idle_1.dae", blendInDuration: 0.0)
        }
    }
    public var handModelProxy: HandModel {
        // Make sure this has a unique name so it isn't replaced by the same model it's representing
        let handModel = self.handModel
        handModel.rename(to: "idle-proxy")
        return handModel
    }
    
    private init() { }
    
    func resetCamera() {
        self.sceneController.positionCameraFacing(
            position: SCNVector3(0.015, 1.66, 0.39),
            // Position the camera and look direction +0.06
            // Effectively translates the scene down 0.06 whilst maintaining the defaultCameraController target
            positionOffset: SCNVector3(0.0, 0.06, 0.0),
            targetOffset: SCNVector3(0.0, 0.06, 0.0),
            distance: Environment.inst.deviceType == .pad ? 0.5 : 0.7
        )
    }
    
    func resetCameraFromBack() {
        self.sceneController.positionCameraFacing(
            position: SCNVector3(0.015, 1.66, 0.39),
            // Position the camera and look direction +0.4
            // Effectively translates the scene down 0.4 whilst maintaining the defaultCameraController target
            positionOffset: SCNVector3(0.0, Environment.inst.deviceType == .pad ? 0.3 : 0.4, 0.0),
            targetOffset: SCNVector3(0.0, Environment.inst.deviceType == .pad ? 0.3 : 0.4, 0.0),
            distance: Environment.inst.deviceType == .pad ? -0.5 : -0.7
        )
        self.sceneController.getCamera().setEulerAngles(
            x: -1.0 * .pi * 25.0 / 180.0,   // Look down -25 deg
            y: .pi                          // Turn around 180 deg
        )
    }
    
    func pointCameraToModel() {
        if let activeModel = self.sequence?.handModel {
            self.sceneController.positionCameraFacing(model: activeModel)
        }
    }
    
    func setupScene() {
        let camera = SceneCamera()
            .setRenderDistance(far: 500.0, near: 0.0)
        self.sceneController.setCamera(to: camera)
        self.resetCamera()
        
        if SettingsSession.inst.settings.realisticHandModel {
            self.setupRealisticLights()
        } else {
            self.setupSimpleLights()
        }
        
        self.sceneController.setCameraControl(allowed: true)
        self.sceneController.setBackgroundColor(to: LimeColors.sceneFill)
    }
    
    func setupSimpleLights() {
        self.sceneController.clearLights()
        
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
    }
    
    func setupRealisticLights() {
        self.sceneController.clearLights()
        
        let highlights = SceneLight(id: "highlights")
            .setType(to: .omni)
            .setColor(to: .white)
            .setPosition(to: SCNVector3(x: 0, y: 10, z: 2))
            .setIntensity(to: 100)
        self.sceneController.addLight(highlights)
        
        let frontLight = SceneLight(id: "frontLight")
            .setType(to: .directional)
            .setColor(to: .white)
            .setIntensity(to: 800)
            .setTemperature(to: 6300)
            .setPosition(to: SCNVector3(x: 0, y: 8, z: 10))
            .direct(to: SCNVector3())
        self.sceneController.addLight(frontLight)
        
        let backLight = SceneLight(id: "backLight")
            .setType(to: .directional)
            .setColor(to: .white)
            .setIntensity(to: 800)
            .setTemperature(to: 6200)
            .setPosition(to: SCNVector3(x: 0, y: 8, z: -10))
            .direct(to: SCNVector3())
        self.sceneController.addLight(backLight)
        
        let ambientLight = SceneLight(id: "ambient")
            .setType(to: .ambient)
            .setColor(to: .white)
            .setIntensity(to: 600)
            .setTemperature(to: 6300)
        self.sceneController.addLight(ambientLight)
    }
    
    func clearLetterSequence() {
        self.sequence?.unmount()
        self.sequence = nil
        self.activePrompt = ""
    }
    
    func addLetterSequence(prompt: String) -> Bool {
        if SettingsSession.inst.settings.smoothTransitions {
            return self.addBlendedLetterSequence(prompt: prompt)
        } else {
            return self.addSequentialLetterSequence(prompt: prompt)
        }
    }
    
    private func addSequentialLetterSequence(prompt: String) -> Bool {
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
        var animationModels = [HandModel]()
        let subDir = self.animationModelFileDirectory
        let suffix = self.animationFileSuffix
        for char in prompt {
            animationModels.append(HandModel(subDir: subDir, fileName: "\(char)\(suffix).dae", blendInDuration: 0.0))
        }
        self.sequence = HandModelSequence(
            handModel: self.handModel,
            animationModels: animationModels
        )
        self.sequence?.mount(to: self.sceneController)
        return true
    }
    
    private func addBlendedLetterSequence(prompt: String) -> Bool {
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
        var animationModels = [HandModel]()
        let subDir = self.animationModelFileDirectory
        let suffix = self.animationFileSuffix
        for char in prompt {
            animationModels.append(HandModel(subDir: subDir, fileName: "\(char)\(suffix).dae", blendInDuration: 0.55))
        }
        self.sequence = HandModelSequence(
            handModel: self.handModel,
            animationModels: animationModels
        )
        self.sequence?.mount(to: self.sceneController)
        return true
    }
    
    private func cleanPrompt(prompt: String) -> String {
        let cleaned = prompt.lowercased().filter({ $0.isLetter })
        return String(cleaned)
    }
    
}
