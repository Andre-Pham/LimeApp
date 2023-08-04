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
    
    private var root: LimeView { return LimeView(self.view) }
    private let toolbarContainer = LimeView()
    private let toolbarStack = LimeVStack()
    private let toolbarRow1 = LimeHStack()
    private let promptToggle = LimeChipButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attach(scene: SpellSession.inst.sceneController)
        SpellSession.inst.setupScene()
        
        self.root
            .addSubview(self.toolbarContainer)
        
        self.toolbarContainer
            .constrainHorizontal(padding: 15)
            .constrainBottom(padding: 20)
            .setBackgroundColor(to: .white)
            .setCornerRadius(to: 30)
            .addSubview(self.toolbarStack)

        self.toolbarStack
            .constrainAllSides(padding: 15)
            .addView(self.toolbarRow1)

        self.toolbarRow1
            .constrainHorizontal()
            .addView(self.promptToggle)
            .addSpacer()
        
        self.promptToggle
            .setIcon(to: "character.cursor.ibeam")
    }
    
    func attach(scene: SceneController) {
        scene.attach(to: self)
    }
    
}
