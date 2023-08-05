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
    
    /// The constraint used to anchor the toolbar - adjustable and animatable for keyboard avoidance
    private var toolbarConstraint: NSLayoutConstraint!
    
    private var root: LimeView { return LimeView(self.view) }
    private let toolbarContainer = LimeView()
    private let toolbarStack = LimeVStack()
    private let toolbarRowDefault = LimeHStack()
    private let toolbarRowPrompt = LimeHStack()
    private let toolbarRowTimeline = LimeHStack()
    private let promptToggle = LimeChipToggle()
    private let timelineToggle = LimeChipToggle()
    private let cameraButton = LimeChipButton()
    private let playButton = LimeChipToggle()
    private let promptInput = LimeTextInput()
    private let animationSpeedMultiState = LimeChipMultiState<Double>()
    
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
            .constrainHorizontal(padding: LimeDimensions.toolbarPaddingHorizontal)
            .setBackgroundColor(to: .white)
            .setCornerRadius(to: LimeDimensions.backgroundCornerRadius)
            .addSubview(self.toolbarStack)
        
        // Setup constraint for keyboard avoidance
        self.toolbarConstraint = self.toolbarContainer.bottomAnchor.constraint(
            equalTo: self.root.bottomAnchor,
            constant: -LimeDimensions.toolbarPaddingBottom
        )
        self.toolbarConstraint.isActive = true

        self.toolbarStack
            .constrainAllSides(padding: LimeDimensions.toolbarInnerPadding)
            .setSpacing(to: LimeDimensions.toolbarSpacing)
            .addView(self.toolbarRowDefault)

        self.toolbarRowDefault
            .constrainHorizontal()
            .setSpacing(to: LimeDimensions.toolbarSpacing)
            .addView(self.promptToggle)
            .addView(self.timelineToggle)
            .addView(self.cameraButton)
            .addSpacer()
            .addView(self.playButton)
        
        self.toolbarRowPrompt
            .setSpacing(to: LimeDimensions.toolbarSpacing)
            .addView(self.promptInput)
        
        self.toolbarRowTimeline
            .setSpacing(to: LimeDimensions.toolbarSpacing)
            .addSpacer()
            .addView(self.animationSpeedMultiState)
        
        self.animationSpeedMultiState
            .setFixedWidth(width: 90)
            .addState(value: 1.0, label: "1x")
            .addState(value: 1.5, label: "1.5x")
            .addState(value: 0.25, label: "0.25x")
            .addState(value: 0.5, label: "0.5x")
            .setOnChange({ playbackSpeed in
                
            })
        
        self.promptToggle
            .setIcon(to: "character.cursor.ibeam")
            .setOnTap({ isEnabled in
                if isEnabled {
                    self.toolbarStack.addViewAnimated(
                        self.toolbarRowPrompt,
                        position: self.toolbarStack.viewCount == 1 ? 0 : 1
                    )
                    self.toolbarRowPrompt.constrainHorizontal()
                } else {
                    self.toolbarStack.removeViewAnimated(self.toolbarRowPrompt)
                }
            })
        
        self.timelineToggle
            .setIcon(to: "slider.horizontal.below.rectangle")
            .setOnTap({ isEnabled in
                if isEnabled {
                    print(self.toolbarStack.viewCount)
                    self.toolbarStack.addViewAnimated(self.toolbarRowTimeline,position: 0)
                    self.toolbarRowTimeline.constrainHorizontal()
                } else {
                    self.toolbarStack.removeViewAnimated(self.toolbarRowTimeline)
                }
            })
        
        self.cameraButton
            .setIcon(to: "cube.transparent")
        
        self.promptInput
            .setFont(to: LimeFont(font: LimeFonts.IBMPlexMono.Medium.rawValue, size: 18))
            .setPlaceholder(to: Strings("label.prompt").local)
        
        self.playButton
            .setColor(enabled: LimeColors.primaryButtonFill, disabled: LimeColors.primaryButtonFill)
            .setIconColor(enabled: LimeColors.primaryButtonText, disabled: LimeColors.primaryButtonText)
            .setIcon(to: "play.fill", disabled: "pause.fill")
            .setDefaultState(enabled: true) // Start paused
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func attach(scene: SceneController) {
        scene.attach(to: self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            let viewControllerHeight = self.view.frame.size.height
            let screenHeight = UIScreen.main.bounds.height
            let tabBarHeight = screenHeight - viewControllerHeight
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.toolbarConstraint.constant = -keyboardHeight + tabBarHeight - LimeDimensions.toolbarPaddingBottom
                self?.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.toolbarConstraint.constant = -LimeDimensions.toolbarPaddingBottom
            self?.view.layoutIfNeeded()
        }
    }
    
}
