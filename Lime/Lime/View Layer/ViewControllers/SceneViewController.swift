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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attach(scene: SpellSession.inst.sceneController)
        SpellSession.inst.setupScene()
    }
    
    func attach(scene: SceneController) {
        scene.attach(to: self)
    }
    
}
