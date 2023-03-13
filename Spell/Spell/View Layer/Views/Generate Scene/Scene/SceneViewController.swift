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
    
    private var scene: SCNScene = SCNScene()
    
    func setupTestSceneView(with scene: SCNScene) {
        self.scene = scene

        let sceneView = SCNView(frame: self.view.frame)
        self.view.addSubview(sceneView)
        
        sceneView.allowsCameraControl = true

        sceneView.scene = scene
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 3.0)
        let light = SCNLight()
        light.type = SCNLight.LightType.omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 1.5, y: 1.5, z: 1.5)
        let cubeGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        let cubeNode = SCNNode(geometry: cubeGeometry)
        cubeNode.name = "cube"
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(cubeNode)
        
        camera.zFar = 500.0
        
        self.sceneView = sceneView
        self.camera = cameraNode
        self.setScenePause(to: true)
    }
    
    func setupSceneView(with scene: SCNScene) {
        self.scene = scene
        
//        scene.rootNode.enumerateChildNodes { (node, stop) in
//            if node.name == nil {
//                print("REMOVING")
//                node.removeFromParentNode()
//            }
//        }
        
        // Create an SCNFloor object with a white color
        let floor = SCNFloor()
        floor.firstMaterial?.diffuse.contents = UIColor.red
        // Create an SCNNode with the SCNFloor geometry and add it to the scene
        let floorNode = SCNNode(geometry: floor)
        floorNode.name = "floor"
        scene.rootNode.addChildNode(floorNode)
        
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15) //TODO: Setup camera position
        self.camera = cameraNode
        cameraNode.camera?.zFar = 500.0

        let lightNode = SCNNode()
        lightNode.name = "light"
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.light?.color = UIColor.green
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.name = "ambient light"
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
//        let mesh = scene.rootNode.childNode(withName: "Hands", recursively: true)
//        let player = mesh?.animationPlayer(forKey: "transform")
//        if let player {
//            print(player.paused)
//            //player.stop()
//        }
        
        //let mesh = scene.rootNode.childNode(withName: "Hands", recursively: true)
        //mesh?.position = SCNVector3(0, 0, 0)

        //let sceneView = SCNView(frame: CGRect(x: 0.0, y: 0.0, width: 500.0, height: 1000.0))
        let sceneView = SCNView(frame: self.view.frame)
        sceneView.delegate = self
        sceneView.scene = scene
        sceneView.allowsCameraControl = true
        //sceneView.backgroundColor = UIColor(red: 0.89, green: 0.91, blue: 1.00, alpha: 1.00)
        self.view.addSubview(sceneView)
        
        self.sceneView = sceneView
        
        print(scene.rootNode.childNodes.map({ $0.name }))
        print(scene.rootNode.childNodes.map({ $0.animationKeys }))
        print(scene.rootNode.childNodes.map({ $0.actionKeys }))
        
        self.setScenePause(to: true)
        
        
        

    }
    

    
    private(set) var camera: SCNNode = SCNNode()
    private(set) var sceneView: SCNView = SCNView()
    
    func setCameraTowardModel() {
        let modelNode = self.scene.rootNode.childNode(withName: "Hands", recursively: true)!
        let camera = self.camera
        let sceneView = self.sceneView
        
        let boundingBox = modelNode.boundingBox
        let center = SCNVector3((boundingBox.min.x + boundingBox.max.x) / 2, (boundingBox.min.y + boundingBox.max.y) / 2, (boundingBox.min.z + boundingBox.max.z) / 2)
        //let cameraPosition = SCNVector3(center.x, center.y, boundingBox.max.z + Float(abs(boundingBox.max.z - boundingBox.min.z)))
        //camera.position = cameraPosition
        camera.look(at: center)
        sceneView.pointOfView = camera
    }
    
    func printPosition() {
        print(self.scene.rootNode.position)
        self.scene.rootNode.childNodes.forEach({
            print(($0.name ?? "NO NAME") + ": " + "(\($0.position.x), \($0.position.y), \($0.position.z))")
        })
        print("-----")
    }
    
    func printNames() {
        self.printNodes(node: self.scene.rootNode)
    }
    
    func printNodes(node: SCNNode, prefix: String = ">") {
        var statement = prefix + " "
        statement += node.name ?? "nil"
        statement += ": "
        statement += "(\(node.position.x), \(node.position.y), \(node.position.z))"
        statement += " | "
        statement += "(\(node.presentation.boundingBox.min.x), \(node.presentation.boundingBox.min.y), \(node.presentation.boundingBox.min.z), \(node.presentation.boundingBox.max.x), \(node.presentation.boundingBox.max.y), \(node.presentation.boundingBox.max.z))"
        print(statement)
        for childNode in node.childNodes {
            self.printNodes(node: childNode, prefix: prefix + ">")
        }
    }
    
    func positionCameraToLookAt(nodeName: String) {
        //let node = self.scene.rootNode.presentation
        //let node = self.scene.rootNode.childNode(withName: "group1", recursively: true)!.presentation
        let node = self.scene.rootNode.childNode(withName: nodeName, recursively: true)!.presentation
        let camera = self.camera
        let sceneView = self.sceneView
        
//        node.animationKeys.
//        node.animationPlayer(forKey: <#T##String#>)
//        node.animationPlayer(forKey: <#T##String#>)?.animation.

        
        
        // Calculate the bounding box of the node
        let boundingBox = node.boundingBox
        
        // Calculate the center point of the bounding box
        let center = SCNVector3Make(
            (boundingBox.min.x + boundingBox.max.x) * 0.5,
            (boundingBox.min.y + boundingBox.max.y) * 0.5,
            (boundingBox.min.z + boundingBox.max.z) * 0.5
        )
        
        // Calculate the distance from the center of the bounding box to the camera
        let distance = Float(boundingBox.max.z - boundingBox.min.z) * 2.0
        
        // Position the camera
        camera.position = SCNVector3Make(center.x, center.y, center.z + distance)
        
        // Make the camera look at the node
        camera.look(at: center)
        
        // Set the camera as the point of view for the scene
        sceneView.pointOfView = camera
    }
    
    
    
    func setScenePause(to isPaused: Bool) {
        self.scene.rootNode.isPaused = isPaused
    }
    
}
