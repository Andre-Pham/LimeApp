//
//  Scene.swift
//  Spell
//
//  Created by Andre Pham on 17/3/2023.
//

import SceneKit
import Foundation

class SceneController {
    
    private var scene: SCNScene
    private var sceneView: SCNView = SCNView()
    private var sceneCamera = SceneCamera()
    private var sceneLights = [SceneLight]()
    private var sceneGeometry = [SceneGeometry]()
    
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
        if let replacementIndex = self.sceneGeometry.firstIndex(where: { $0.name == sceneGeometry.name }) {
            self.sceneGeometry[replacementIndex].remove()
            self.sceneGeometry[replacementIndex] = sceneGeometry
        } else {
            self.sceneGeometry.append(sceneGeometry)
        }
    }
    
    private func removeNode(named name: String) {
        for index in stride(from: self.sceneLights.count - 1, through: 0, by: -1) {
            let sceneLight = self.sceneLights[index]
            if sceneLight.name == name {
                sceneLight.remove()
                self.sceneLights.remove(at: index)
            }
        }
        for index in stride(from: self.sceneGeometry.count - 1, through: 0, by: -1) {
            let sceneGeometry = self.sceneGeometry[index]
            if sceneGeometry.name == name {
                sceneGeometry.remove()
                self.sceneGeometry.remove(at: index)
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
        guard let node = self.scene.rootNode.childNode(withName: nodeName, recursively: true)?.presentation else {
            return
        }
        
        // Calculate the bounding box of the node
        let boundingBox = node.boundingBox
        
        // Calculate the center point of the bounding box
//        let center = SCNVector3Make(
//            (boundingBox.min.x + boundingBox.max.x) * 0.5,
//            (boundingBox.min.y + boundingBox.max.y) * 0.5,
//            (boundingBox.min.z + boundingBox.max.z) * 0.5
//        )
        
        let center = node.presentation.position
        
        // Calculate the distance from the center of the bounding box to the camera
        let distance = Float(boundingBox.max.z - boundingBox.min.z) * 2.0
        
        self.sceneCamera
            .setPosition(to: SCNVector3Make(center.x, center.y, center.z + distance))
            .direct(to: center)
    }
    
    func showBoundingBox(nodeName: String, color: UIColor = .red) {
        guard let node = self.scene.rootNode.childNode(withName: nodeName, recursively: true)?.presentation else {
            return
        }
        let min = node.boundingBox.min
        let max = node.boundingBox.max
        var edges = [(SCNVector3, SCNVector3)]()
        edges.append((min, SCNVector3(max.x, min.y, min.z)))
        edges.append((min, SCNVector3(min.x, max.y, min.z)))
        edges.append((SCNVector3(min.x, min.y, max.z), min))
        edges.append((max, SCNVector3(min.x, max.y, max.z)))
        edges.append((max, SCNVector3(max.x, min.y, max.z)))
        edges.append((max, SCNVector3(max.x, max.y, min.z)))
        
        let width = max.x - min.x
        let height = max.y - min.y
        let depth = max.z - min.z
        
        // TODO: Rewrite this to just use min and the width/height/depth
        
        edges.append((SCNVector3(min.x, min.y, min.z + depth), SCNVector3(min.x, max.y, min.z + depth)))
        edges.append((SCNVector3(min.x + width, min.y, min.z), SCNVector3(min.x + width, max.y, min.z)))
        
        edges.append((SCNVector3(min.x, min.y + height, min.z), SCNVector3(max.x, min.y + height, min.z)))
        edges.append((SCNVector3(min.x, min.y, min.z + depth), SCNVector3(max.x, min.y, min.z + depth)))
        
        edges.append((SCNVector3(min.x, min.y + height, max.z), SCNVector3(min.x, min.y + height, min.z)))
        edges.append((SCNVector3(min.x + width, min.y, max.z), SCNVector3(min.x + width, min.y, min.z)))
        
        for edge in edges {
            let geometry = SceneGeometry(geometry: GeometryBuilder().cylinder(origin: edge.0, end: edge.1, radius: 0.5))
                .setLightingModel(to: .constant)
                .setColor(to: color)
            self.addGeometry(geometry)
        }
        
//        let centre = SCNVector3(
//            (min.x + max.x)/2.0,
//            (min.y + max.y)/2.0,
//            (min.z + max.z)/2.0
//        )
        let circle = SceneGeometry(geometry: GeometryBuilder().sphere(position: node.position, radius: 1.0))
            .setLightingModel(to: .constant)
            .setColor(to: color)
        self.addGeometry(circle)
    }
    
    func printNames() {
        self.printNodes(node: self.scene.rootNode)
    }
    
    func printNodes(node: SCNNode, prefix: String = ">") {
        let statement = "\(prefix) \(node.toString(position: true, bounding: false))"
        print(statement)
        for childNode in node.childNodes {
            self.printNodes(node: childNode, prefix: prefix + ">")
        }
        
        // TODO: This allows me to speed up / slow down the animation speed
        node.animationKeys.forEach({ key in
            if let animation = node.animationPlayer(forKey: key) {
                print("ANIMATION FOUND")
                print("SPEED: \(animation.speed)")
                animation.speed = 5.0
            }
        })
    }
    
}
