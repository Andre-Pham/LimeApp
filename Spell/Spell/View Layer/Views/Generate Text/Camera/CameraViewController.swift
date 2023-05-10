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
        let tipPosition = positions.indexTip.getDenormalisedPosition(viewWidth: 414, viewHeight: 812)
        print("POSITIONS RECEIVED ON FRAME \(self.currentFrameIndex)")
        assert(Thread.isMainThread, "Predictions should be received on the main thread")
        self.overlayView.subviews.forEach({ $0.removeFromSuperview() })
        let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        circleView.layer.opacity = 0.5
        circleView.center = self.view.center
        circleView.backgroundColor = UIColor.red
        circleView.layer.cornerRadius = circleView.frame.width / 2
        let label = UILabel(frame: circleView.bounds)
        label.textAlignment = .center
        label.textColor = UIColor.white
        if let tipPosition {
            label.text = "\(tipPosition.x.rounded()), \(tipPosition.y.rounded()) | \(Double(positions.indexTip.position!.x).rounded(decimalPlaces: 2)), \(Double(positions.indexTip.position!.y).rounded(decimalPlaces: 2))"
        } else {
            label.text = "missing"
        }
        
        circleView.addSubview(label)
        self.overlayView.addSubview(circleView)
        
//        print(self.view.frame.width)
//        print(self.view.frame.height)
//        print(UIScreen.main.bounds.size.width)
//        print(UIScreen.main.bounds.size.height)
//        print("-----")
        
        // TODO: Make sure self.view.frame is actually correct (I sense it's a little bit off what I'm looking for)
//        let tipPosition = positions.indexTip.getDenormalisedPosition(viewWidth: UIScreen.main.bounds.size.width, viewHeight: UIScreen.main.bounds.size.height)
//        if let tipPosition {
////            print(tipPosition)
//            // TODO: Add the confidence data to the positions data and remove the threshold
//            // TODO: Then I can scale the circles by their confidence
//            let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
//            circleView.center = tipPosition
//            circleView.backgroundColor = UIColor.green
//            circleView.layer.cornerRadius = circleView.frame.width / 2
//            self.view.addSubview(circleView)
//        }
        
        for position in positions.allPositions {
            let positionVal = position.getDenormalisedPosition(viewWidth: self.overlayView.frame.width, viewHeight: self.overlayView.frame.height)
            if let positionVal {
                
    //            print(tipPosition)
                // TODO: Add the confidence data to the positions data and remove the threshold
                // TODO: Then I can scale the circles by their confidence
                let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                circleView.center = positionVal
                circleView.backgroundColor = UIColor.green
                circleView.layer.cornerRadius = circleView.frame.width / 2
                self.overlayView.addSubview(circleView)
            }
        }
        
        if true {
            let testPoints: [CGPoint] = [CGPoint(x: 0, y: 0), CGPoint(x: 1.0, y: 0.0), CGPoint(x: 1.0, y: 1.0), CGPoint(x: 0.0, y: 1.0), CGPoint(x: 0.5, y: 0.5)]
            for testPoint in testPoints {
                positions.indexTip.position = testPoint
                //let aspectRatio = CGFloat(self.currentFrame!.width)/CGFloat(self.currentFrame!.height)
                let tipPosition = positions.indexTip.getDenormalisedPosition(viewWidth: self.overlayView.frame.width, viewHeight: self.overlayView.frame.height)
//                print(tipPosition)
                let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                circleView.layer.opacity = 1.0
                circleView.center = tipPosition!
                circleView.backgroundColor = UIColor.orange
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
//        self.view.contentMode = .scaleAspectFill
//        self.view.contentMode = .scaleAspectFill
        
//        self.imageView.contentMode = .scaleAspectFill
//        self.imageView.contentMode = .scaleToFil
//        self.imageView.frame = self.view.bounds
//        self.view.addSubview(self.imageView)
        self.view.addSubview(self.overlayView)
        
//        self.overlayView.frame = CGRect(x: 0, y: 0, width: 200, height: 400)
        
        self.view.layer.borderColor = CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
        self.view.layer.borderWidth = 1.5
        self.imageView.layer.borderColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
        self.imageView.layer.borderWidth = 5
        self.overlayView.layer.borderColor = CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.5)
        self.overlayView.layer.borderWidth = 2.5
        
        
        // 0.47 0.75 at 200, 200
        // 0.84 0.5  at 400, 400
        // expected: 425 to 476 x 800
        // self.view.frame = 414, 812
        // UIScreen.main.bounds.size = 414, 896
        // frame = 480, 640
    }
    
    private func setView(to image: CGImage) {
        (self.view as! UIImageView).image = UIImage(cgImage: image)
//        self.imageView.image = UIImage(cgImage: image)
//        let aspectRatio = CGFloat(self.currentFrame!.width)/CGFloat(self.currentFrame!.height)
//        var overlayFrame = CGRect(
//            x: 0,
//            y: 0,
//            width: self.view.frame.width,
//            height: self.view.frame.height
//        )
        var overlaySize = self.imageView.image!.size
        var overlayFrame = CGRect(origin: CGPoint(), size: overlaySize).scale(toAspectFillSize: self.view.frame.size)
        overlayFrame.origin.x += self.view.frame.center.x - overlayFrame.center.x
        overlayFrame.origin.y += self.view.frame.center.y - overlayFrame.center.y
        self.overlayView.frame = overlayFrame
//        self.overlayView.frame = CGRect(x: 0, y: 0, width: 200, height: 400)
    }
    
}
