//
//  CameraViewController.swift
//  Spell
//
//  Created by Andre Pham on 12/4/2023.
//

import Foundation
import UIKit
import AVFoundation
import Vision
import SceneKit

class CameraViewController: UIViewController, CaptureDelegate, SignDelegate {
    
    private static let PREDICTION_INTERVAL = 1
    
    private let captureSession = CaptureSession()
    private let signRecogniser = SignRecogniser()
    private var currentFrame: CGImage? = nil
    private var currentFrameID = 0
    private var overlayFrameSyncRequired = true
    
    override func viewDidLoad() {
        self.setupView()
        self.setupSignRecogniser()
        // Stop the device automatically sleeping
        UIApplication.shared.isIdleTimerDisabled = true
        
        self.setupAndBeginCapturingVideoFrames()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.captureSession.stopCapturing {
            super.viewWillDisappear(animated)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // React to change in device orientation
        self.setupAndBeginCapturingVideoFrames()
        self.overlayFrameSyncRequired = true
    }
    
    override func viewDidLayoutSubviews() {
        self.overlayFrameSyncRequired = true
    }
    
    func onCapture(session: CaptureSession, frame: CGImage?) {
        if let frame {
            self.currentFrameID += 1
            self.currentFrame = frame
            
            if self.currentFrameID%Self.PREDICTION_INTERVAL == 0 {
                self.currentFrameID = 0
                self.signRecogniser.makePrediction(on: frame)
            }
            
            self.setView(to: frame)
        }
    }
    
    func onPrediction(outcome: Label) {
        assert(Thread.isMainThread, "Predictions should be received on the main thread")
        // Do nothing
    }
    
    func onPredictionPositions(outcome: Label, positions: JointPositions) {
        assert(Thread.isMainThread, "Predictions should be received on the main thread")
        self.overlayView.subviews.forEach({ $0.removeFromSuperview() })
        
        for position in positions.allPositions {
            let positionVal = position.getDenormalisedPosition(viewWidth: self.overlayView.frame.width, viewHeight: self.overlayView.frame.height)
            if let positionVal {
                print(position.confidence!)
                let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 18.0*CGFloat(position.confidence!), height: 18.0*CGFloat(position.confidence!)))
                circleView.center = positionVal
                circleView.backgroundColor = UIColor.green
                circleView.layer.cornerRadius = circleView.frame.width / 2
                self.overlayView.addSubview(circleView)
            }
        }
    }
    
    func flipCamera() {
        self.captureSession.flipCamera { error in
            if let error {
                assertionFailure("Failed to flip camera: \(error)")
                return
            }
        }
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
    
    private func setupSignRecogniser() {
        self.signRecogniser.signDelegate = self
    }
    
    private var imageView = UIImageView()
    private var overlayView = UIView()
    
    private func setupView() {
        self.view = self.imageView
        self.view.contentMode = .scaleAspectFill
        self.view.addSubview(self.overlayView)
    }
    
    private func setView(to image: CGImage) {
        self.imageView.image = UIImage(cgImage: image)
        if self.overlayFrameSyncRequired {
            self.matchOverlayFrame()
            self.overlayFrameSyncRequired = false
        }
    }
    
    private func matchOverlayFrame() {
        let overlaySize = self.imageView.image!.size
        var overlayFrame = CGRect(origin: CGPoint(), size: overlaySize).scale(toAspectFillSize: self.view.frame.size)
        // Align overlay frame center to view center
        overlayFrame.origin.x += self.view.frame.center.x - overlayFrame.center.x
        overlayFrame.origin.y += self.view.frame.center.y - overlayFrame.center.y
        self.overlayView.frame = overlayFrame
    }
    
}
