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
    /// True if the too close warning is active
    private var tooCloseWarningActive: Bool {
        return self.tooCloseWarning.hasSuperView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.handDetector.handDetectionDelegate = self
        RecognitionQuizSession.inst.recognitionQuizDelegate = self
        RecognitionQuizSession.inst.setLetterPrompt(to: "ABC")
        
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
        
        self.tooCloseWarning
            .setWarning(to: Strings("label.tooClose").local)
        
        // Stop the device automatically sleeping
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.image.resetImage()
        self.quizPrompt.removeFromSuperView()
        self.tooCloseWarning.removeFromSuperView()
        self.setupAndBeginCapturingVideoFrames()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.root.addSubview(self.dialogue)
        self.dialogue
            .removeCancel()
            .setTitle(to: Strings("dialogue.title.experimental").local)
            .setBody(to: Strings("dialogue.body.experimental").local)
            .setAcceptButtonText(to: Strings("button.getStarted").local)
            .constrainCenterVertical()
            .constrainCenterHorizontal()
            .animateEntrance(duration: 1.2)
            .setOnAccept({
                self.dialogue.animateExit {
                    self.dialogue.removeFromSuperView()
                    self.addQuizPrompt(letter: RecognitionQuizSession.inst.displayLetter)
                    RecognitionQuizSession.inst.markReadyForInput()
                }
            })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.captureSession.stopCapturing()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // React to change in device orientation
        self.setupAndBeginCapturingVideoFrames()
    }
    
    func onCorrectSignPerformed(letter: Character, next: Character) {
        RecognitionQuizSession.inst.disableInput()
        self.quizPrompt.markCorrect() {
            self.quizPrompt.animateExit {
                self.quizPrompt.removeFromSuperView()
                self.quizPrompt.reset()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.addQuizPrompt(letter: next)
                    RecognitionQuizSession.inst.markReadyForInput()
                }
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
                RecognitionQuizSession.inst.receiveHandDetectionOutcome(outcome)
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
            let palmToTipLength = handDetection.getDenormalisedPalmToTipLength(frameSize: self.root.frame.size)
            let tooClose = isGreater(
                palmToTipLength,
                min(self.root.frame.size.height*0.8, self.root.frame.size.width*1.2)
            )
            let grayArea = isGreater(
                palmToTipLength,
                min(self.root.frame.size.height*0.65, self.root.frame.size.width)
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
