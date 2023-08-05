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
    private let toolbarRowDefault = LimeHStack()
    private let toolbarRowPrompt = LimeHStack()
    private let promptToggle = LimeChipToggle()
    private let timelineToggle = LimeChipToggle()
    private let cameraButton = LimeChipButton()
    private let promptInput = LimeTextInput()
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attach(scene: SpellSession.inst.sceneController)
        SpellSession.inst.setupScene()
        
        self.root
            .addSubview(self.toolbarContainer)
        
        self.toolbarContainer
            .constrainHorizontal(padding: 15)
//            .constrainBottom(padding: 20)
            .setBackgroundColor(to: .white)
            .setCornerRadius(to: 30)
            .addSubview(self.toolbarStack)

        self.toolbarStack
            .constrainAllSides(padding: 15)
            .setSpacing(to: 10)
            .addView(self.toolbarRowDefault)

        self.toolbarRowDefault
            .constrainHorizontal()
            .setSpacing(to: 10)
            .addView(self.promptToggle)
            .addView(self.timelineToggle)
            .addView(self.cameraButton)
            .addSpacer()
        
        self.toolbarRowPrompt
            .setSpacing(to: 10)
            .addView(self.promptInput)
        
        self.promptToggle
            .setIcon(to: "character.cursor.ibeam")
            .setOnTap({ isEnabled in
                if isEnabled {
                    self.toolbarStack.addViewAnimated(self.toolbarRowPrompt, position: 0)
                    self.toolbarRowPrompt.constrainHorizontal()
                } else {
                    self.toolbarStack.removeViewAnimated(self.toolbarRowPrompt)
                }
            })
        
        self.timelineToggle
            .setIcon(to: "slider.horizontal.below.rectangle")
        
        self.cameraButton
            .setIcon(to: "cube.transparent")
        
        self.promptInput
            .setText(to: "Hello World")
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.bottomConstraint = self.toolbarContainer.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        self.bottomConstraint.isActive = true
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                tapGesture.cancelsTouchesInView = false
                view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
            view.endEditing(true)
        }
    
    var bottomConstraint: NSLayoutConstraint!
    
    func attach(scene: SceneController) {
        scene.attach(to: self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                let keyboardHeight = keyboardSize.height
            
            let viewControllerHeight = self.view.frame.size.height
            let screenHeight = UIScreen.main.bounds.height
            let tabBarHeight = screenHeight - viewControllerHeight
            
            print(self.view.frame.size.height)
            print(self.view.superview?.frame.size.height)
            print(self.toolbarContainer.view.frame.origin.y)
            print(self.toolbarContainer.view.frame.origin.y + self.toolbarContainer.view.frame.height)
            
            let viewFrameInViewControllerView = self.view.convert(self.toolbarContainer.frame, from: self.view.superview)
            let viewBottomY = self.toolbarContainer.view.frame.origin.y + (self.view.superview?.frame.origin.y ?? 0.0)
            let distanceFromBottom = self.view.frame.size.height - viewBottomY
//            print(distanceFromBottom)


                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.bottomConstraint.constant = -keyboardHeight + tabBarHeight - 20
                    self?.view.layoutIfNeeded()
                }
            }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.bottomConstraint.constant = -20
            self?.view.layoutIfNeeded()
        }
    }
    
}
