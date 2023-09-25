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
    private var quizPrompt = QuizPromptView()
    
    /// The camera capture session for producing a camera output
    private let captureSession = CaptureSession()
    /// The model used for detecting hands within a frame
    private let handDetector = HandDetector()
    /// The active frame being shown
    private var activeFrame: CGImage? = nil
    private let quizHost = RecognitionQuizHost()
    
    private let testButton = LimeIconButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAndBeginCapturingVideoFrames()
        self.handDetector.handDetectionDelegate = self
        self.quizHost.recognitionQuizDelegate = self
        self.quizHost.setLetterPrompt(to: "ABC")
        
        self.root
            .addSubview(self.image)
            .addSubview(self.handOverlayView)
            .addSubview(self.testButton)
        
        self.image
            .constrainAllSides(respectSafeArea: false)
            .setContentMode(to: .scaleAspectFill)
        
        self.handOverlayView
            .constrainAllSides(respectSafeArea: false)
        
        self.quizPrompt
            .setPromptText(to: Strings("label.perform").local)
        
        self.testButton
            .constrainCenterVertical()
            .constrainCenterHorizontal()
            .setIcon(to: "plus")
            .setOnTap({
                self.quizPrompt
                    .animateExit {
                        self.quizPrompt.removeFromSuperView()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.root.addSubview(
                                self.quizPrompt
                                    .animateEntrance()
                            )
                            self.quizPrompt
                                .constrainCenterHorizontal(to: self.root)
                                .constrainTop(to: self.root, padding: LimeDimensions.floatingCardTopPadding)
                        }
                    }
            })
        
        // Stop the device automatically sleeping
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // React to change in device orientation
        self.setupAndBeginCapturingVideoFrames()
    }
    
    func onCorrectSignPerformed(letter: Character, next: Character) {
        self.quizPrompt
            .animateExit {
                self.quizPrompt.removeFromSuperView()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.quizPrompt
                        .setLetter(to: next)
                    self.root.addSubview(
                        self.quizPrompt
                            .animateEntrance()
                    )
                    self.quizPrompt
                        .constrainCenterHorizontal(to: self.root)
                        .constrainTop(to: self.root, padding: LimeDimensions.floatingCardTopPadding)
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
