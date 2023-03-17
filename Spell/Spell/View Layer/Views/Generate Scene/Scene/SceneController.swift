//
//  Scene.swift
//  Spell
//
//  Created by Andre Pham on 17/3/2023.
//

import SceneKit
import Foundation

class SceneController {
    
    private static let CAMERA_NODE_NAME = "camera"
    
    private var scene: SCNScene
    private var sceneView: SCNView = SCNView()
    private var sceneCamera = SceneCamera()
    private var sceneLights = [SceneLight]()
    
    private var lightNodeNames: [String] {
        return self.sceneLights.map({ $0.name })
    }
    
    init(scene: SCNScene = SCNScene()) {
        self.scene = scene
        self.sceneView.scene = self.scene
        self.sceneCamera.add(to: self.sceneView)
    }
    
    func attach(to controller: UIViewController) {
        self.sceneView.frame = controller.view.frame
        controller.view.subviews.forEach({
            if $0 is SCNView {
                $0.removeFromSuperview()
            }
        })
        if let delegate = controller as? SCNSceneRendererDelegate {
            self.sceneView.delegate = delegate
        }
        controller.view.addSubview(self.sceneView)
    }
    
    func setCamera(to sceneCamera: SceneCamera) {
        self.sceneCamera.remove()
        sceneCamera.add(to: self.sceneView)
        self.sceneCamera = sceneCamera
    }
    
    func addLight(_ sceneLight: SceneLight) {
        sceneLight.add(to: self.sceneView)
        if let replacementIndex = self.sceneLights.firstIndex(where: { $0.name == sceneLight.name }) {
            self.sceneLights[replacementIndex].remove()
            self.sceneLights[replacementIndex] = sceneLight
        } else {
            self.sceneLights.append(sceneLight)
        }
    }
    
    func addGeometry(_ sceneGeometry: SceneGeometry) {
        sceneGeometry.add(to: self.sceneView)
    }
    
    private func removeNode(named name: String) {
        for index in stride(from: self.sceneLights.count - 1, through: 0, by: -1) {
            let sceneLight = self.sceneLights[index]
            if sceneLight.name == name {
                sceneLight.remove()
                self.sceneLights.remove(at: index)
            }
        }
        if self.sceneCamera.name == name {
            self.sceneCamera.remove()
            self.sceneCamera = SceneCamera()
        }
        self.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == name {
                node.removeFromParentNode()
            }
        }
    }
    
    func setScenePause(to isPaused: Bool) {
        self.scene.rootNode.isPaused = isPaused
    }
    
    func setCameraControl(allowed: Bool) {
        self.sceneView.allowsCameraControl = allowed
    }
    
    func positionCameraToLookAt(nodeName: String) {
        let node = self.scene.rootNode.childNode(withName: nodeName, recursively: true)!.presentation
        
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
        
        self.sceneCamera
            .setPosition(to: SCNVector3Make(center.x, center.y, center.z + distance))
            .direct(to: center)
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
    
}
