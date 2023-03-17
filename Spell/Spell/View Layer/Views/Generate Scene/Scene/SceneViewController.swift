//
//  SceneViewController.swift
//  Spell
//
//  Created by Andre Pham on 8/3/2023.
//

import Foundation
import UIKit
import SceneKit

class SceneViewController: UIViewController, SCNSceneRendererDelegate {
    
    private(set) var scene: SceneController = SceneController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attach(scene: self.scene)
    }
    
    func attach(scene: SceneController) {
        scene.attach(to: self)
        self.scene = scene
        
        let camera = SceneCamera()
            .setPosition(to: SCNVector3(x: 0, y: 0, z: 15))
            .setRenderDistance(far: 300.0)
        scene.setCamera(to: camera)
         
        let floor = SceneGeometry(id: "floor", geometry: SCNFloor())
            .setColor(to: .blue)
        scene.addGeometry(floor)
        
        let mainLight = SceneLight(id: "main")
            .setType(to: .omni)
            .setColor(to: UIColor.green)
            .setPosition(to: SCNVector3(x: 0, y: 10, z: 10))
        let ambientLight = SceneLight(id: "ambient")
            .setType(to: .ambient)
            .setColor(to: UIColor.red)
        scene.addLight(mainLight)
        scene.addLight(ambientLight)
        
        scene.setCameraControl(allowed: true)
        scene.setScenePause(to: true)
    }
    
}
