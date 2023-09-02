//
//  SceneViewController.swift
//  Lime
//
//  Created by Andre Pham on 8/3/2023.
//

import Foundation
import UIKit
import SceneKit

class SceneViewController: UIViewController, SCNSceneRendererDelegate, OnSettingsChangedSubscriber {
    
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
    private let toolbarRowCamera = LimeHStack()
    private let promptToggle = LimeChipToggle()
    private let timelineToggle = LimeChipToggle()
    private let cameraToggle = LimeChipToggle()
    private let cameraButton = LimeChipTextButton()
    private let reverseCameraButton = LimeChipTextButton()
    private let playButton = LimeChipToggle()
    private let promptInput = LimeTextInput()
    private let animationSpeedMultiState = LimeChipMultiState<Double>()
    private let timeline = ScrubberView()
    private let letterDisplay = LetterDisplayView()
    
    private let idleModel = HandModel(subDir: "alphabet1", fileName: "Idle_1.dae", blendInDuration: 0.0)
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attach(scene: LimeSession.inst.sceneController)
        LimeSession.inst.setupScene()
        OnSettingsChangedPublisher.subscribe(self)
        self.idleModel.setOpacity(to: 0.0)
        LimeSession.inst.sceneController.addModel(self.idleModel)
        
        self.root
            .setBackgroundColor(to: LimeColors.sceneFill)
            .addSubview(self.toolbarContainer)
            .addSubview(self.letterDisplay)
        
        self.toolbarContainer
            .constrainHorizontal(padding: LimeDimensions.toolbarPaddingHorizontal)
            .setBackgroundColor(to: LimeColors.toolbarFill)
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
            .setHidden(to: SettingsSession.inst.settings.hidePrompt)

        self.toolbarStack
            .constrainAllSides(padding: LimeDimensions.toolbarInnerPadding)
            .setSpacing(to: LimeDimensions.toolbarSpacing)
            .addView(self.toolbarRowDefault)

        self.toolbarRowDefault
            .constrainHorizontal()
            .setSpacing(to: LimeDimensions.toolbarSpacing)
            .addView(self.promptToggle)
            .addView(self.timelineToggle)
            .addSpacer()
            .addView(self.playButton)
        
        self.toolbarRowPrompt
            .setSpacing(to: LimeDimensions.toolbarSpacing)
            .addView(self.promptInput)
        
        self.toolbarRowTimeline
            .setSpacing(to: LimeDimensions.toolbarSpacing)
            .addView(self.timeline)
            .addView(self.animationSpeedMultiState)
        
        if Environment.inst.deviceType == .pad {
            self.toolbarRowDefault
                .insertView(self.reverseCameraButton, at: 2)
                .insertView(self.cameraButton, at: 3)
        } else {
            self.toolbarRowDefault.insertView(self.cameraToggle, at: 2)
            self.toolbarRowCamera
                .setSpacing(to: LimeDimensions.toolbarSpacing)
                .setDistribution(to: .fillEqually)
                .addView(self.reverseCameraButton)
                .addView(self.cameraButton)
        }
        
        self.timeline
            .constrainVertical()
            .setOnStartTracking({
//                // If we're mid transition we need to interrupt it
//                LimeSession.inst.sequence?.interruptTransition()
                // Save the animation speed because we're about to slow the model down
//                self.animationSpeedCache = LimeSession.inst.sequence?.animationSpeed ?? 1.0
                // The model appears in the starting position during tracking unless playing
                // Slow down the animation so it appears not to play
//                LimeSession.inst.sequence?.setAnimationSpeed(to: 0.001)
                LimeSession.inst.sequence?.setSequencePause(to: false, noBlend: true)
                LimeSession.inst.sequence?.handModel.setOpacity(to: 0.0)
                
                if !LimeSession.inst.activePrompt.isEmpty {
                    self.idleModel.setOpacity(to: 1.0)
                }
            })
            .setOnEndTracking({
                // Resume state - delay to guarantee model doesn't appear in starting position
                LimeSession.inst.sequence?.handModel.setOpacity(to: 1.0)
                
               
                
                LimeSession.inst.sequence?.setSequencePause(to: false, noBlend: true)
                self.animationSpeedCache = LimeSession.inst.sequence?.animationSpeed ?? 1.0
                LimeSession.inst.sequence?.setAnimationSpeed(to: 0.001)
                
                if self.playButton.isEnabled {
                    LimeSession.inst.sequence?.handModel.setOpacity(to: 0.0)
                    if !LimeSession.inst.activePrompt.isEmpty {
                        self.idleModel.setOpacity(to: 1.0)
                    }
                } else {
                    self.idleModel.setOpacity(to: 0.0)
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    LimeSession.inst.sequence?.setAnimationSpeed(to: self.animationSpeedCache)
                    LimeSession.inst.sequence?.setSequencePause(to: self.playButton.isEnabled)
                    
                }
                
                
//                LimeSession.inst.sequence?.setAnimationSpeed(to: self.animationSpeedCache)
            })
            .setOnChange({ proportion in
                if self.timeline.isTracking {
                    if !LimeSession.inst.activePrompt.isEmpty {
                        self.idleModel.setOpacity(to: 1.0)
                    }
                    LimeSession.inst.sequence?.setSequencePause(to: true, noBlend: true)
                    var clampedProportion = LimeSession.inst.sequence?.clampToAnimationStart(progressProportion: proportion) ?? 0.0
                    if isGreaterOrEqual(clampedProportion, 1.0) {
                        clampedProportion = LimeSession.inst.sequence?.clampToAnimationStart(progressProportion: 0.0) ?? 0.0
                    }
                    self.timeline.setProgress(to: clampedProportion)
                    if let lastPosition = self.lastPosition, !Lime.isEqual(lastPosition, clampedProportion) {
                        self.hapticFeedback.impactOccurred()
                    }
                    self.lastPosition = clampedProportion
                    if let letterIndex = LimeSession.inst.sequence?.lastPlayedIndex {
                        self.letterDisplay.focusLetter(letterIndex, duration: 0.2)
                    }
                }
//                if self.timeline.isTracking {
//                    LimeSession.inst.sequence?.uninterruptTransition()
//                    let clampedProportion = LimeSession.inst.sequence?.clampToAnimationStart(proportion: proportion) ?? 0.0
//                    self.timeline.setProgress(to: clampedProportion)
//                    if let lastPosition = self.lastPosition, !Lime.isEqual(lastPosition, clampedProportion) {
//                        self.hapticFeedback.impactOccurred()
//                    }
//                    self.lastPosition = clampedProportion
//                    if let letterIndex = LimeSession.inst.sequence?.activeModelIndex {
//                        self.letterDisplay.focusLetter(letterIndex, duration: 0.2)
//                    }
//                }
            })
        
        self.animationSpeedMultiState
            .setFixedWidth(width: 90)
            .addState(value: 1.0, label: "1x")
            .addState(value: 1.5, label: "1.5x")
            .addState(value: 0.25, label: "0.25x")
            .addState(value: 0.5, label: "0.5x")
            .setOnChange({ playbackSpeed in
                LimeSession.inst.sequence?.setAnimationSpeed(to: playbackSpeed)
            })
        
        self.promptToggle
            .setIcon(to: "character.cursor.ibeam")
            .setOnTap({ isEnabled in
                if isEnabled {
                    var position = 0
                    if self.timelineToggle.isEnabled {
                        position += 1
                    }
                    if self.cameraToggle.isEnabled {
                        position += 1
                    }
                    self.toolbarStack.addViewAnimated(self.toolbarRowPrompt, position: position)
                    self.toolbarRowPrompt.constrainHorizontal()
                } else {
                    self.toolbarStack.removeViewAnimated(self.toolbarRowPrompt)
                }
            })
        
        self.timelineToggle
            .setIcon(to: "slider.horizontal.below.rectangle")
            .setOnTap({ isEnabled in
                if isEnabled {
                    var position = 0
                    if self.cameraToggle.isEnabled {
                        position += 1
                    }
                    self.toolbarStack.addViewAnimated(self.toolbarRowTimeline, position: position)
                    self.toolbarRowTimeline.constrainHorizontal()
                    // If you add any delay, the code block occurs after the view's update batch
                    // If you don't, the view isn't updated because it's not "existent" because it hasn't been added yet
                    // Triggering the code after the animation also works but has a delay - this updates faster
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        self.timeline.setProgress(to: LimeSession.inst.sequence?.animationProgressProportion ?? 0.0)
                    }
                } else {
                    self.toolbarStack.removeViewAnimated(self.toolbarRowTimeline)
                }
            })
        
        self.cameraToggle
            .setIcon(to: "rotate.3d")
            .setOnTap({ isEnabled in
                if isEnabled {
                    self.toolbarStack.addViewAnimated(self.toolbarRowCamera, position: 0)
                    self.toolbarRowCamera.constrainHorizontal()
                } else {
                    self.toolbarStack.removeViewAnimated(self.toolbarRowCamera)
                }
            })
        
        self.cameraButton
            .setIcon(to: "video")
            .setLabel(to: Strings("label.viewFront").local)
            .setLabelSize(to: 17)
            .setIconWidth(to: 32)
            .setOnTap({
                LimeSession.inst.resetCamera()
            })
        
        self.reverseCameraButton
            .setIcon(to: "video")
            .setLabel(to: Strings("label.viewBack").local)
            .setLabelSize(to: 17)
            .setIconWidth(to: 32)
            .setOnTap({
                LimeSession.inst.resetCameraFromBack()
            })
        
        self.promptInput
            .setFont(to: LimeFont(font: LimeFonts.IBMPlexMono.Medium.rawValue, size: 18))
            .setPlaceholder(to: Strings("label.prompt").local)
            .setSubmitLabel(to: .go)
            .setOnFocus({
                self.pauseScene()
            })
            .setOnUnfocus({
                self.promptInput.setText(to: LimeSession.inst.activePrompt)
            })
            .setOnSubmit({
                let newSequenceMounted = LimeSession.inst.addLetterSequence(prompt: self.promptInput.text)
                if newSequenceMounted {
                    self.letterDisplay.setPrompt(to: LimeSession.inst.activePrompt)
                    if !LimeSession.inst.activePrompt.isEmpty {
                        self.letterDisplay.focusLetter(0, duration: 0.5)
                    }
                    self.resetToolbar()
                }
            })
        
        self.playButton
            .setColor(enabled: LimeColors.primaryButtonFill, disabled: LimeColors.primaryButtonFill)
            .setIconColor(enabled: LimeColors.textPrimaryButton, disabled: LimeColors.textPrimaryButton)
            .setIcon(to: "play.fill", disabled: "pause.fill")
            .setState(enabled: true) // Start paused
            .setOnTap({ isPaused in
                self.idleModel.setOpacity(to: 0.0)
                LimeSession.inst.sequence?.setSequencePause(to: isPaused, noBlend: true)
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
                if let letterIndex = LimeSession.inst.sequence?.lastPlayedIndex {
                    self.letterDisplay.focusLetter(letterIndex, duration: 0.5)
                }
            }
        }
        
        /*let testModel = SceneModel(node: HandModelSequence(handModels: [
            HandModel(subDir: "alphabet1", fileName: "a_1.dae", blendInDuration: 0.4),
            HandModel(subDir: "alphabet1", fileName: "b_1.dae", blendInDuration: 0.4),
            HandModel(subDir: "alphabet1", fileName: "c_1.dae", blendInDuration: 0.4),
            HandModel(subDir: "alphabet1", fileName: "d_1.dae", blendInDuration: 0.4),
        ]).node)
        
        LimeSession.inst.sceneController.addModel(testModel)
        
        return*/
    }
    
    func resetToolbar() {
        self.timeline.setProgress(to: 0.0)
        self.animationSpeedMultiState.setState(state: 0)
    }
    
    func pauseScene() {
        if !self.playButton.isEnabled {
            self.playButton.setState(enabled: true, trigger: true)
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
    
    func onSettingsChanged(old: LimeSettings, new: LimeSettings) {
        if old.hidePrompt != new.hidePrompt {
            self.letterDisplay.setHidden(to: new.hidePrompt)
        }
        if old.smoothTransitions != new.smoothTransitions || old.leftHanded != new.leftHanded {
            self.pauseScene()
            if !LimeSession.inst.activePrompt.isEmpty {
                LimeSession.inst.clearLetterSequence()
                self.promptInput.setText(to: "")
                self.letterDisplay.setPrompt(to: LimeSession.inst.activePrompt)
                self.resetToolbar()
            }
        }
    }
    
}
