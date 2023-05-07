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
    
    private static let PREDICTION_INTERVAL = 15
    
    private let captureSession = CaptureSession()
    private let signRecogniser = SignRecogniser()
    private var currentFrame: CGImage? = nil
    // TODO: Modulo this
    private var currentFrameIndex = 0
    
    override func viewDidLoad() {
        self.setupView()
        self.setupSignRecogniser()
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
    }
    
    func onCapture(session: CaptureSession, frame: CGImage?) {
        if let frame {
            self.currentFrameIndex += 1
            self.currentFrame = frame
            
            if self.currentFrameIndex%Self.PREDICTION_INTERVAL == 0 {
                self.signRecogniser.makePrediction(on: frame)
            }
            
            self.setView(to: frame)
        }
    }
    
    func onPrediction(outcome: Label) {
        assert(Thread.isMainThread, "Predictions should be received on the main thread")
    }
    
    func onPredictionPositions(outcome: Label, positions: JointPositions) {
        print("POSITIONS RECEIVED ON FRAME \(self.currentFrameIndex)")
        assert(Thread.isMainThread, "Predictions should be received on the main thread")
        self.view.subviews.forEach({ $0.removeFromSuperview() })
        let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        circleView.center = self.view.center
        circleView.backgroundColor = UIColor.red
        circleView.layer.cornerRadius = circleView.frame.width / 2
        let label = UILabel(frame: circleView.bounds)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.text = "\(self.currentFrameIndex)"
        circleView.addSubview(label)
        self.view.addSubview(circleView)
        
        // TODO: Make sure self.view.frame is actually correct (I sense it's a little bit off what I'm looking for)
        let tipPosition = positions.indexTip.getDenormalisedPosition(viewWidth: self.view.frame.width, viewHeight: self.view.frame.height)
        if let tipPosition {
            // TODO: Add the confidence data to the positions data and remove the threshold
            // TODO: Then I can scale the circles by their confidence
            let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            circleView.center = tipPosition
            circleView.backgroundColor = UIColor.green
            circleView.layer.cornerRadius = circleView.frame.width / 2
            self.view.addSubview(circleView)
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
    
    private func setupView() {
        self.view = UIImageView()
        self.view.contentMode = .scaleAspectFill
    }
    
    private func setView(to image: CGImage) {
        (self.view as! UIImageView).image = UIImage(cgImage: image)
    }
    
}
