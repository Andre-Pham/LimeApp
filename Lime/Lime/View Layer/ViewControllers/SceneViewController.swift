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
    /// Caches the animation speed of the animation
    private var animationSpeedCache = 1.0
    
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
    private let timeline = ScrubberView()
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attach(scene: SpellSession.inst.sceneController)
        SpellSession.inst.setupScene()
        
        SpellSession.inst.addInterpolatedLetterSequence(prompt: "arar")
        
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
        
        // MARK: - Notes
        // Pause during transition
        // Scrub backwards after transition is done
        // It keeps playing

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
            .addView(self.timeline)
            .addView(self.animationSpeedMultiState)
        
        self.timeline
            .constrainVertical()
            .setOnStartTracking({
                // If we're mid transition we need to interrupt it
                SpellSession.inst.sequence?.interruptTransition()
                // Save the animation speed because we're about to slow the model down
                self.animationSpeedCache = SpellSession.inst.sequence?.animationSpeed ?? 1.0
                // The model appears in the starting position during tracking unless playing
                // Slow down the animation so it appears not to play
                SpellSession.inst.sequence?.setSequenceAnimationSpeed(to: 0.001)
                SpellSession.inst.sequence?.playSequence()
            })
            .setOnEndTracking({
                // Resume state - delay to guarantee model doesn't appear in starting position
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    SpellSession.inst.sequence?.setSequencePause(to: self.playButton.isEnabled)
                    SpellSession.inst.sequence?.setSequenceAnimationSpeed(to: self.animationSpeedCache)
                }
            })
            .setOnChange({ proportion in
                if self.timeline.isTracking {
                    SpellSession.inst.sequence?.setRestartTransitionWasInterrupted(to: false)
                    let clampedProportion = SpellSession.inst.sequence?.clampToAnimationStart(proportion: proportion) ?? 0.0
                    self.timeline.setProgress(to: clampedProportion)
//                    self.activeLetter = SpellSession.inst.sequence?.activeModel.description ?? "-"
                }
            })
        
        self.animationSpeedMultiState
            .setFixedWidth(width: 90)
            .addState(value: 1.0, label: "1x")
            .addState(value: 1.5, label: "1.5x")
            .addState(value: 0.25, label: "0.25x")
            .addState(value: 0.5, label: "0.5x")
            .setOnChange({ playbackSpeed in
                SpellSession.inst.sequence?.setSequenceAnimationSpeed(to: playbackSpeed)
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
                    self.toolbarStack.addViewAnimated(self.toolbarRowTimeline,position: 0)
                    self.toolbarRowTimeline.constrainHorizontal()
                } else {
                    self.toolbarStack.removeViewAnimated(self.toolbarRowTimeline)
                }
            })
        
        self.cameraButton
            .setIcon(to: "cube.transparent")
            .setOnTap({
                if let activeModel = SpellSession.inst.sequence?.activeModel {
                    SpellSession.inst.sceneController.positionCameraFacing(model: activeModel)
                }
            })
        
        self.promptInput
            .setFont(to: LimeFont(font: LimeFonts.IBMPlexMono.Medium.rawValue, size: 18))
            .setPlaceholder(to: Strings("label.prompt").local)
        
        self.playButton
            .setColor(enabled: LimeColors.primaryButtonFill, disabled: LimeColors.primaryButtonFill)
            .setIconColor(enabled: LimeColors.primaryButtonText, disabled: LimeColors.primaryButtonText)
            .setIcon(to: "play.fill", disabled: "pause.fill")
            .setDefaultState(enabled: true) // Start paused
            .setOnTap({ isPaused in
                SpellSession.inst.sequence?.setSequencePause(to: isPaused)
            })
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { timer in
            let sequence = SpellSession.inst.sequence
            if !self.timeline.isTracking, let proportion = sequence?.animationProgressProportion {
                if !self.playButton.isEnabled {
                    self.timeline.setProgress(to: proportion)
                }
//                self.activeLetter = SpellSession.inst.sequence?.activeModel.description ?? "-"
            }
        }
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
