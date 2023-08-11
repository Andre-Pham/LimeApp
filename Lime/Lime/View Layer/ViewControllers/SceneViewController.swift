//
//  SceneViewController.swift
//  Lime
//
//  Created by Andre Pham on 8/3/2023.
//

import Foundation
import UIKit
import SceneKit

class SceneViewController: UIViewController, SCNSceneRendererDelegate, OnTransitionDelegate {
    
    /// The constraint used to anchor the toolbar - adjustable and animatable for keyboard avoidance
    private var toolbarConstraint: NSLayoutConstraint!
    /// Caches the animation speed of the animation
    private var animationSpeedCache = 1.0
    /// The last position of the scrubber to use as a reference to see if it was just clamped to a new position
    private var lastPosition: Double? = nil
    /// A haptic feedback generator to use within the view controller as feedback
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
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
    private let letterDisplay = LetterDisplayView()
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attach(scene: LimeSession.inst.sceneController)
        LimeSession.inst.setupScene()
        
        self.root
            .setBackgroundColor(to: LimeColors.sceneFill)
            .addSubview(self.toolbarContainer)
            .addSubview(self.letterDisplay)
        
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
        
        self.letterDisplay
            .constrainCenterHorizontal()
            .constrainTop(padding: 50)

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
                LimeSession.inst.sequence?.interruptTransition()
                // Save the animation speed because we're about to slow the model down
                self.animationSpeedCache = LimeSession.inst.sequence?.animationSpeed ?? 1.0
                // The model appears in the starting position during tracking unless playing
                // Slow down the animation so it appears not to play
                LimeSession.inst.sequence?.setSequenceAnimationSpeed(to: 0.001)
                LimeSession.inst.sequence?.playSequence()
            })
            .setOnEndTracking({
                // Resume state - delay to guarantee model doesn't appear in starting position
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    LimeSession.inst.sequence?.setSequencePause(to: self.playButton.isEnabled)
                    LimeSession.inst.sequence?.setSequenceAnimationSpeed(to: self.animationSpeedCache)
                }
            })
            .setOnChange({ proportion in
                if self.timeline.isTracking {
                    LimeSession.inst.sequence?.uninterruptTransition()
                    let clampedProportion = LimeSession.inst.sequence?.clampToAnimationStart(proportion: proportion) ?? 0.0
                    self.timeline.setProgress(to: clampedProportion)
                    if let lastPosition = self.lastPosition, !Lime.isEqual(lastPosition, clampedProportion) {
                        self.hapticFeedback.impactOccurred()
                    }
                    self.lastPosition = clampedProportion
                    if let letterIndex = LimeSession.inst.sequence?.activeModelIndex {
                        self.letterDisplay.centerLetter(letterIndex, duration: 0.2)
                    }
                }
            })
        
        self.animationSpeedMultiState
            .setFixedWidth(width: 90)
            .addState(value: 1.0, label: "1x")
            .addState(value: 1.5, label: "1.5x")
            .addState(value: 0.25, label: "0.25x")
            .addState(value: 0.5, label: "0.5x")
            .setOnChange({ playbackSpeed in
                LimeSession.inst.sequence?.setSequenceAnimationSpeed(to: playbackSpeed)
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
                if let activeModel = LimeSession.inst.sequence?.activeModel {
                    LimeSession.inst.sceneController.positionCameraFacing(model: activeModel)
                }
            })
        
        self.promptInput
            .setFont(to: LimeFont(font: LimeFonts.IBMPlexMono.Medium.rawValue, size: 18))
            .setPlaceholder(to: Strings("label.prompt").local)
            .setSubmitLabel(to: .go)
            .setOnFocus({
                if !self.playButton.isEnabled {
                    self.playButton.setState(enabled: true, trigger: true)
                }
            })
            .setOnUnfocus({
                self.promptInput.setText(to: LimeSession.inst.activePrompt)
            })
            .setOnSubmit({
                let newSequenceMounted = LimeSession.inst.addInterpolatedLetterSequence(prompt: self.promptInput.text)
                if newSequenceMounted {
                    LimeSession.inst.sequence?.setOnTransitionDelegate(to: self)
                    self.letterDisplay.setPrompt(to: LimeSession.inst.activePrompt)
                    self.letterDisplay.centerLetter(0, duration: 0.5)
                    self.resetToolbar()
                }
            })
        
        self.playButton
            .setColor(enabled: LimeColors.primaryButtonFill, disabled: LimeColors.primaryButtonFill)
            .setIconColor(enabled: LimeColors.textPrimaryButton, disabled: LimeColors.textPrimaryButton)
            .setIcon(to: "play.fill", disabled: "pause.fill")
            .setState(enabled: true) // Start paused
            .setOnTap({ isPaused in
                LimeSession.inst.sequence?.setSequencePause(to: isPaused)
            })
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // If the user taps anywhere on-screen, cancel the keyboard
        // Note the keyboard dismissal callback triggers first, then the tap
        // E.g. if you press a button while the keyboard is open, the keyboard closes, then the button press is triggered
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { timer in
            let sequence = LimeSession.inst.sequence
            if !self.timeline.isTracking, let proportion = sequence?.animationProgressProportion {
                if !self.playButton.isEnabled {
                    self.timeline.setProgress(to: proportion)
                    self.lastPosition = proportion
                }
            }
        }
    }
    
    func onTransition(duration: Double) {
        if let letterIndex = LimeSession.inst.sequence?.activeModelIndex {
            let letterCount = LimeSession.inst.activePrompt.count
            self.letterDisplay.centerLetter((letterIndex + 1)%letterCount, duration: duration)
        }
    }
    
    func resetToolbar() {
        self.timeline.setProgress(to: 0.0)
        self.animationSpeedMultiState.setState(state: 0)
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
