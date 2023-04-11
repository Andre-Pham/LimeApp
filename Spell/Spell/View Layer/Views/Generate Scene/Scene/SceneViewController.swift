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
            .setRenderDistance(far: 500.0)
        scene.setCamera(to: camera)
         
//        let floor = SceneGeometry(id: "floor", geometry: GeometryBuilder.floor())
//            .setColor(to: .blue)
//        scene.addGeometry(floor)
//        
//        let cylinder = SceneGeometry(id: "cylinder1", geometry: GeometryBuilder.cylinder(origin: SCNVector3(0.0, 1.0, 0.0), end: SCNVector3(5, 1, 0), radius: 0.1))
//            .setLightingModel(to: .constant)
//            .setColor(to: .green)
//        scene.addGeometry(cylinder)
//        
//        let cylinder2 = SceneGeometry(id: "cylinder2", geometry: GeometryBuilder.cylinder(origin: SCNVector3(5, 1, 0), end: SCNVector3(0, 5, 0), radius: 0.1))
//            .setLightingModel(to: .constant)
//            .setColor(to: .red)
//        scene.addGeometry(cylinder2)
//        
//        let cylinder3 = SceneGeometry(id: "cylinder3", geometry: GeometryBuilder.cylinder(origin: SCNVector3(0, 5, 0), end: SCNVector3(0, 1, 0), radius: 0.1))
//            .setLightingModel(to: .constant)
//            .setColor(to: .purple)
//        scene.addGeometry(cylinder3)
//        
//        let sphere1 = SceneGeometry(id: "origin", geometry: GeometryBuilder.sphere(position: SCNVector3(0.0, 1.0, 0.0), radius: 0.3))
//            .setLightingModel(to: .constant)
//            .setColor(to: .orange)
//        scene.addGeometry(sphere1)
//        
//        let sphere2 = SceneGeometry(id: "middle", geometry: GeometryBuilder.sphere(position: SCNVector3(5.0, 1.0, 0.0), radius: 0.3))
//            .setLightingModel(to: .constant)
//            .setColor(to: .orange)
//        scene.addGeometry(sphere2)
//        
//        let sphere3 = SceneGeometry(id: "end", geometry: GeometryBuilder.sphere(position: SCNVector3(0.0, 5.0, 0.0), radius: 0.3))
//            .setLightingModel(to: .constant)
//            .setColor(to: .orange)
//        scene.addGeometry(sphere3)
        
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
