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
    
    /// The camera capture session for producing a camera output
    private let captureSession = CaptureSession()
    /// The model used for detecting hands within a frame
    private let handDetector = HandDetector()
    /// The active frame being shown
    private var activeFrame: CGImage? = nil
    private let quizHost = RecognitionQuizHost()
    
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
            .animateEntrance(duration: 1.5)
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
        }
    }
    
    func onHandDetection(outcome: HandDetectionOutcome?) {
        if let outcome {
            self.handOverlayView.draw(for: outcome)
            self.quizHost.receiveHandDetectionOutcome(outcome)
        }
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
