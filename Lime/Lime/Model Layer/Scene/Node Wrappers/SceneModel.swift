//
//  SceneModel.swift
//  Lime
//
//  Created by Andre Pham on 9/4/2023.
//

import Foundation
import SceneKit

protocol SceneModel {
    
    var namePrefix: String { get }
    var node: SCNNode { get }
    var name: String { get }
    
}
extension SceneModel {
    
    func add(to sceneView: SCNView) {
        sceneView.scene?.rootNode.addChildNode(self.node)
    }
    
    func remove() {
        self.node.removeFromParentNode()
    }
    
    func setOpacity(to opacity: Double) {
        self.node.opacity = opacity
    }
    
}
