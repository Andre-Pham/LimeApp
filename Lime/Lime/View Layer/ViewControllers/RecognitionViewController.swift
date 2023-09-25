//
//  RecognitionViewController.swift
//  Lime
//
//  Created by Andre Pham on 21/9/2023.
//

import Foundation
import CoreGraphics
import UIKit

class RecognitionViewController: UIViewController, CaptureDelegate, HandDetectionDelegate, RecognitionQuizDelegate {
    
    private var root: LimeView { return LimeView(self.view) }
    private let image = LimeImage()
    private let handOverlayView = HandOverlayView()
    private let quizPrompt = QuizPromptView()
    private let dialogue = LimeDialogueBox()
    private let tooCloseWarning = CameraWarningView()
    
    /// The camera capture session for producing a camera output
    private let captureSession = CaptureSession()
    /// The model used for detecting hands within a frame
    private let handDetector = HandDetector()
    /// The active frame being shown
    private var activeFrame: CGImage? = nil
    /// The frame id used as a counter to run anything on every nth frame
    @WrapsToZero(threshold: 600) private var currentFrameID = 0
    private let quizHost = RecognitionQuizHost()
    /// True if the too close warning is active
    private var tooCloseWarningActive: Bool {
        return self.tooCloseWarning.hasSuperView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAndBeginCapturingVideoFrames()
        self.handDetector.handDetectionDelegate = self
        self.quizHost.recognitionQuizDelegate = self
        self.quizHost.setLetterPrompt(to: "ABC")
        
        self.root
            .setBackgroundColor(to: LimeColors.backgroundFill)
            .addSubview(self.image)
            .addSubview(self.handOverlayView)
        
        self.image
            .constrainAllSides(respectSafeArea: false)
            .setContentMode(to: .scaleAspectFill)
        
        self.handOverlayView
            .constrainAllSides(respectSafeArea: false)
        
        self.quizPrompt
            .setPromptText(to: Strings("label.perform").local)
        
        // Stop the device automatically sleeping
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.root.addSubview(self.dialogue)
        self.dialogue
            .removeCancel()
            .setTitle(to: "Experimental!")
            .setBody(to: "This is an experimental feature for demo purposes, intended to give an idea of how fingerspelling recognition would feel and be implemented. It's limited to three letters: A, B, C.")
            .setAcceptButtonText(to: "Get Started")
            .constrainCenterVertical()
            .constrainCenterHorizontal()
            .animateEntrance(duration: 1.2)
            .setOnAccept({
                self.dialogue.animateExit {
                    self.dialogue.removeFromSuperView()
                    self.addQuizPrompt(letter: self.quizHost.displayLetter)
                    self.quizHost.markReadyForInput()
                }
            })
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // React to change in device orientation
        self.setupAndBeginCapturingVideoFrames()
    }
    
    func onCorrectSignPerformed(letter: Character, next: Character) {
        self.quizHost.disableInput()
        self.quizPrompt
            .animateExit {
                self.quizPrompt.removeFromSuperView()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.addQuizPrompt(letter: next)
                    self.quizHost.markReadyForInput()
                }
            }
    }
    
    func onCapture(session: CaptureSession, frame: CGImage?) {
        if let frame {
            self.handDetector.makePrediction(on: frame)
            self.setVideoImage(to: frame)
            self.activeFrame = frame
            self.currentFrameID += 1
        }
    }
    
    func onHandDetection(outcome: HandDetectionOutcome?) {
        if let outcome {
            self.handOverlayView.draw(for: outcome)
            if !self.tooCloseWarningActive {
                self.quizHost.receiveHandDetectionOutcome(outcome)
            }
            
            self.updateTooCloseWarning(with: outcome)
        }
    }
    
    private func updateTooCloseWarning(with outcome: HandDetectionOutcome) {
        guard !self.dialogue.hasSuperView else {
            return
        }
        var amountTooClose = 0
        var amountNotTooClose = 0
        var amountThatMeetsConfidenceThreshold = 0
        var amountInGrayArea = 0
        for handDetection in outcome.handDetections {
            let meetsConfidenceThreshold = isGreater(handDetection.averageConfidence, 0.85)
            let tooClose = isGreater(
                handDetection.getDenormalisedPalmToTipLength(frameSize: self.root.frame.size),
                self.root.frame.size.height*0.8
            )
            let grayArea = isGreater(
                handDetection.getDenormalisedPalmToTipLength(frameSize: self.root.frame.size),
                self.root.frame.size.height*0.7
            ) && !tooClose || isGreater(handDetection.averageConfidence, 0.80) && !meetsConfidenceThreshold
            if grayArea {
                amountInGrayArea += 1
                continue
            }
            if tooClose && !self.tooCloseWarningActive {
                amountTooClose += 1
            } else if !tooClose {
                amountNotTooClose += 1
            }
            if meetsConfidenceThreshold {
                amountThatMeetsConfidenceThreshold += 1
            }
        }
        if amountInGrayArea == outcome.handDetections.count {
            // If it's in a gray area, we don't change the warning
            // If it's too close, we say it's still to close
            // If it's acceptable, we say it's still acceptable
            // This way, it doesn't constantly flip between showing and hiding the warning if we're just on the line between too close and not too close
            return
        } else if (amountNotTooClose == outcome.handDetections.count || amountThatMeetsConfidenceThreshold == 0) && self.tooCloseWarningActive {
            self.tooCloseWarning.animateExit {
                self.tooCloseWarning.removeFromSuperView()
            }
        } else if amountTooClose > 0 && amountThatMeetsConfidenceThreshold > 0 && !self.tooCloseWarningActive {
            self.root
                .addSubview(self.tooCloseWarning)
            self.tooCloseWarning
                .constrainCenterVertical()
                .constrainCenterHorizontal()
                .setWarning(to: "Too close")
                .animateEntrance(duration: 0.6)
        }
        
        // Flashes between meeting confidence threshold and being too close, and not meeting threshold
    }
    
    private func addQuizPrompt(letter: Character) {
        self.quizPrompt
            .setLetter(to: letter)
        self.root.addSubview(
            self.quizPrompt
                .animateEntrance()
        )
        self.quizPrompt
            .constrainCenterHorizontal(to: self.root)
            .constrainTop(to: self.root, padding: LimeDimensions.floatingCardTopPadding)
    }

    private func setVideoImage(to image: CGImage) {
        self.image.setImage(image)
    }
    
    private func setupAndBeginCapturingVideoFrames() {
        self.captureSession.setUpAVCapture { error in
            if let error {
                assertionFailure("Failed to setup camera: \(error)")
                return
            }
            
            self.captureSession.captureDelegate = self
            self.captureSession.startCapturing()
        }
    }
    
}
