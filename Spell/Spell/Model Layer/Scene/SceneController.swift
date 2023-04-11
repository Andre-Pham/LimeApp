//
//  Scene.swift
//  Spell
//
//  Created by Andre Pham on 17/3/2023.
//

import SceneKit
import Foundation

class SceneController {
    
    public static let ROOT_NODE_NAME = "root"
    
    private var scene = SCNScene()
    private var sceneView: SCNView = SCNView()
    private var sceneModels = [SceneModel]()
    private var sceneCamera = SceneCamera()
    private var sceneLights = [SceneLight]()
    private var sceneGeometry = [SceneGeometry]()
    
    private var lightNodeNames: [String] {
        return self.sceneLights.map({ $0.name })
    }
    
    init() {
        self.sceneView.scene = self.scene
        self.sceneCamera.add(to: self.sceneView)
        self.scene.rootNode.name = Self.ROOT_NODE_NAME
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
    
    func addModel(_ sceneModel: SceneModel) {
        sceneModel.add(to: self.sceneView)
        if let replacementIndex = self.sceneModels.firstIndex(where: { $0.name == sceneModel.name }) {
            self.sceneModels[replacementIndex].remove()
            self.sceneModels[replacementIndex] = sceneModel
        } else {
            self.sceneModels.append(sceneModel)
        }
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
    
    func positionCameraFacing(nodeName: String, distance: Float = 120.0) {
        guard let node = self.scene.rootNode.childNode(withName: nodeName, recursively: true)?.presentation else {
            return
        }
        var centre = node.presentation.position
        if let boundingBox = SCNBox(node: node) {
            centre = boundingBox.centre
        }
        self.sceneCamera
            .setPosition(to: SCNVector3Make(centre.x, centre.y, centre.z + distance))
            .direct(to: centre)
    }
    
    func showBox(for nodeNames: String...) {
        for name in nodeNames {
            guard let node = self.scene.rootNode.childNode(withName: name, recursively: true) else {
                continue
            }
            guard let edges = SCNBox(node: node)?.edges else {
                continue
            }
            for edge in edges {
                let geometry = SceneGeometry(geometry: GeometryBuilder.cylinder(origin: edge.0, end: edge.1, radius: 0.2))
                    .setLightingModel(to: .constant)
                    .setColor(to: .red)
                self.addGeometry(geometry)
            }
        }
    }
    
    func showPosition(for nodeNames: String...) {
        for name in nodeNames {
            guard let node = self.scene.rootNode.childNode(withName: name, recursively: true) else {
                continue
            }
            let circle = SceneGeometry(geometry: GeometryBuilder.sphere(position: node.presentation.position, radius: 10))
                .setLightingModel(to: .constant)
                .setColor(to: UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.2))
            self.addGeometry(circle)
        }
    }
    
    func showAllBoxes() {
        let nodes = NodeUtil.getHierarchy(for: self.scene.rootNode)
        for node in nodes {
            guard let edges = SCNBox(node: node)?.edges else {
                continue
            }
            print("Adding bounding box for: \(node.name ?? "nil")")
            for edge in edges {
                let geometry = SceneGeometry(geometry: GeometryBuilder.cylinder(origin: edge.0, end: edge.1, radius: 0.2))
                    .setLightingModel(to: .constant)
                    .setColor(to: .red)
                self.addGeometry(geometry)
            }
        }
    }
    
    func showAllNodePositions() {
        let nodes = NodeUtil.getHierarchy(for: self.scene.rootNode)
        for node in nodes {
            let circle = SceneGeometry(geometry: GeometryBuilder.sphere(position: node.presentation.position, radius: 10))
                .setLightingModel(to: .constant)
                .setColor(to: UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.2))
            self.addGeometry(circle)
        }
    }
    
    func clearGeometry() {
        for geometry in self.sceneGeometry {
            self.removeNode(named: geometry.name)
        }
    }
    
    func printNames() {
        NodeUtil.printHierarchy(for: self.scene.rootNode)
    }
    
}
