//
//  SceneLight.swift
//  Lime
//
//  Created by Andre Pham on 13/3/2023.
//

import Foundation
import SceneKit

class SceneLight {
    
    public static let NAME_PREFIX = "light"
    
    private let node = SCNNode()
    private let light = SCNLight()
    var name: String {
        return self.node.name!
    }
    
    init(id: String = UUID().uuidString) {
        self.node.name = "\(Self.NAME_PREFIX)-\(id)"
        self.node.light = self.light
    }
    
    func add(to sceneView: SCNView) {
        sceneView.scene?.rootNode.addChildNode(self.node)
    }
    
    func remove() {
        self.node.removeFromParentNode()
    }
    
    @discardableResult
    func setPosition(to position: SCNVector3) -> Self {
        self.node.position = position
        return self
    }
    
    @discardableResult
    func setColor(to color: UIColor) -> Self {
        self.light.color = color
        return self
    }
    
    @discardableResult
    func setType(to type: SCNLight.LightType) -> Self {
        self.light.type = type
        return self
    }
    
    @discardableResult
    func direct(to position: SCNVector3) -> Self {
        self.node.look(at: position)
        return self
    }
    
    @discardableResult
    func setIntensity(to lumens: Double = 1000.0) -> Self {
        self.light.intensity = lumens
        return self
    }
    
    /// Sets the temperature of the light (in Kelvin).
    /// The default value of 6500 K represents a pure white light (leaving the color unmodulated); lower values (down to a minimum of zero) add a “warmer” yellow or orange effect to the light source, and higher values (up to a maximum of 40000) add a “cooler” blue effect.
    /// - Parameters:
    ///   - kelvin: The temperature (Kelvin)
    /// - Returns: A reference to Self
    @discardableResult
    func setTemperature(to kelvin: Double = 6500.0) -> Self {
        self.light.temperature = kelvin
        return self
    }

}
