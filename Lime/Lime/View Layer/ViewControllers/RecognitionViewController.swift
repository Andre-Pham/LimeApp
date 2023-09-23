//
//  RecognitionViewController.swift
//  Lime
//
//  Created by Andre Pham on 21/9/2023.
//

import Foundation
import UIKit

class JointPositionsView: LimeUIView {
    
    public let view = UIView()
    
    func drawJointPositions(for handDetectionOutcome: HandDetectionOutcome) {
        self.view.subviews.forEach({ $0.removeFromSuperview() })
        for positions in handDetectionOutcome.handDetections {
            for position in positions.allPositions {
                let positionVal = position.getDenormalisedPosition(for: self.view)
                if let positionVal {
                    let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 18.0*CGFloat(position.confidence!), height: 18.0*CGFloat(position.confidence!)))
                    circleView.center = positionVal
                    circleView.backgroundColor = UIColor.green
                    circleView.layer.cornerRadius = circleView.frame.width / 2
                    self.view.addSubview(circleView)
                }
            }
        }
    }
    
}

class RecognitionViewController: UIViewController, CaptureDelegate, HandDetectionDelegate {
    
    private var root: LimeView { return LimeView(self.view) }
    private var image = LimeImage()
    private var jointPositionsOverlay = JointPositionsView()
    private let text = LimeText()
    
    /// The camera capture session for producing a camera output
    private let captureSession = CaptureSession()
    /// The model used for detecting hands within a frame
    private let handDetector = HandDetector()
    /// Indicates if the overlay frames needs to be synced up (frames matched) to the main screen dimensions (e.g. if the device rotates)
    private var overlayFrameSyncRequired = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAndBeginCapturingVideoFrames()
        self.handDetector.handDetectionDelegate = self
        
        self.root
            .addSubview(self.image)
            .addSubview(self.text)
        
        self.image
            .setFrame(to: self.root.frame)
            .addSubview(self.jointPositionsOverlay)
        
        self.text
            .constrainCenterHorizontal()
            .constrainBottom(padding: 20)
            .setBackgroundColor(to: .white)
            .setCornerRadius(to: 6)
            .setPaddingAllSides(to: 12)
            .setFont(to: LimeFont(font: LimeFonts.IBMPlexMono.Bold.rawValue, size: 48))
        
        // Stop the device automatically sleeping
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.image.setFrame(to: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        // React to change in device orientation
        self.setupAndBeginCapturingVideoFrames()
        self.overlayFrameSyncRequired = true
    }
    
    override func viewDidLayoutSubviews() {
        self.overlayFrameSyncRequired = true
    }
    
    func onCapture(session: CaptureSession, frame: CGImage?) {
        if let frame {
            self.handDetector.makePrediction(on: frame)
            self.setVideoImage(to: frame)
        }
    }
    
    func onHandDetection(outcome: HandDetectionOutcome?) {
        if let outcome {
            self.jointPositionsOverlay.drawJointPositions(for: outcome)
            
            if outcome.handDetections.count == 2 {
                let hand1 = outcome.handDetections[0]
                let hand2 = outcome.handDetections[1]
                if let indexTip = hand1.indexTip.position, let thumbTip = hand2.thumbTip.position {
                    let distance = indexTip.length(to: thumbTip)
                    if isLessOrEqual(distance, 0.025) {
                        self.text.setText(to: "A")
                    }
                }
                if let indexTip = hand2.indexTip.position, let thumbTip = hand1.thumbTip.position {
                    let distance = indexTip.length(to: thumbTip)
                    if isLessOrEqual(distance, 0.025) {
                        self.text.setText(to: "A")
                    }
                }
                if let indexTip = hand1.indexTip.position, let otherIndexTip = hand2.indexTip.position {
                    let distance = indexTip.length(to: otherIndexTip)
                    if isLessOrEqual(distance, 0.025) {
                        self.text.setText(to: "E")
                    }
                }
                if let indexTip = hand1.indexTip.position, let middleTip = hand2.middleTip.position {
                    let distance = indexTip.length(to: middleTip)
                    if isLessOrEqual(distance, 0.025) {
                        self.text.setText(to: "I")
                    }
                }
                if let indexTip = hand2.indexTip.position, let middleTip = hand1.middleTip.position {
                    let distance = indexTip.length(to: middleTip)
                    if isLessOrEqual(distance, 0.025) {
                        self.text.setText(to: "I")
                    }
                }
                if let indexTip = hand1.indexTip.position, let ringTip = hand2.ringTip.position {
                    let distance = indexTip.length(to: ringTip)
                    if isLessOrEqual(distance, 0.025) {
                        self.text.setText(to: "O")
                    }
                }
                if let indexTip = hand2.indexTip.position, let ringTip = hand1.ringTip.position {
                    let distance = indexTip.length(to: ringTip)
                    if isLessOrEqual(distance, 0.025) {
                        self.text.setText(to: "O")
                    }
                }
                if let indexTip = hand1.indexTip.position, let littleTip = hand2.littleTip.position {
                    let distance = indexTip.length(to: littleTip)
                    if isLessOrEqual(distance, 0.025) {
                        self.text.setText(to: "U")
                    }
                }
                if let indexTip = hand2.indexTip.position, let littleTip = hand1.littleTip.position {
                    let distance = indexTip.length(to: littleTip)
                    if isLessOrEqual(distance, 0.025) {
                        self.text.setText(to: "U")
                    }
                }
                
                // To detect c:
                // 1. detect if all index fingers follow a circle / oval shape
                // 2. detect if the two fingers are (not) touching
            }
        }
    }
    
    private func setVideoImage(to image: CGImage) {
        self.image.setImage(image)
        if self.overlayFrameSyncRequired {
            self.matchOverlayFrame()
            self.overlayFrameSyncRequired = false
        }
    }
    
    private func matchOverlayFrame() {
        let overlaySize = self.image.imageSize
        var overlayFrame = CGRect(origin: CGPoint(), size: overlaySize).scale(toAspectFillSize: self.image.frame.size)
        // Align overlay frame center to view center
        overlayFrame.origin.x += self.image.frame.center.x - overlayFrame.center.x
        overlayFrame.origin.y += self.image.frame.center.y - overlayFrame.center.y
        self.jointPositionsOverlay.setFrame(to: overlayFrame)
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
