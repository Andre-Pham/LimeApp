//
//  RecognitionViewController.swift
//  Lime
//
//  Created by Andre Pham on 21/9/2023.
//

import Foundation
import CoreGraphics
import UIKit

class RecognitionViewController: UIViewController, CaptureDelegate, HandDetectionDelegate {
    
    private var root: LimeView { return LimeView(self.view) }
    private var image = LimeImage()
    private let handOverlayView = HandOverlayView()
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
            .addSubview(self.handOverlayView)
        
        self.image
            .setFrame(to: self.root.frame)
        
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
            self.activeFrame = frame
        }
    }
    
    private var activeFrame: CGImage? = nil
    
    func onHandDetection(outcome: HandDetectionOutcome?) {
        if let outcome {
            self.handOverlayView.draw(for: outcome)
            
            if let hand1 = outcome.handDetections.first, let frame = self.activeFrame {
                // To detect c:
                // 1. detect if all index fingers follow a circle / oval shape
                // 2. detect if the two fingers are (not) touching
                
                let joints = [
                    hand1.index1, hand1.index2, hand1.index3,
                    hand1.index4, hand1.thumb2, hand1.thumb3,
                    hand1.thumb4
                ]
                let positions: [CGPoint] = joints.compactMap({ $0.getDenormalisedPosition(viewWidth: Double(frame.width), viewHeight: Double(frame.height)) })
                guard positions.count == joints.count else {
                    return
                }
                
                let index2Position = positions[1]
                let index3Position = positions[2]
                let thumb2Position = positions[4]
                let thumb3Position = positions[5]
                
                let circleTop = index2Position.midpoint(relativeTo: index3Position)
                let circleBottom = thumb2Position.midpoint(relativeTo: thumb3Position)
                let circleCenter = circleTop.midpoint(relativeTo: circleBottom)
                let distances = positions.map({ $0.length(to: circleCenter) })
                let radius = (distances.reduce(0.0) { $0 + $1 })/Double(distances.count)
                let maxDistance = distances.max()!
                let minDistance = distances.min()!
                let maxPercentageDifference = maxDistance/radius - 1.0
                let minPercentageDifference = 1.0 - minDistance/radius
                
//                let stat = "MAX: \(maxPercentageDifference.toString(decimalPlaces: 3)) | MIN: \(minPercentageDifference.toString(decimalPlaces: 3))"
//                self.text.setText(to: stat)
                
                if isLessOrEqual(maxPercentageDifference, 0.25) && isLessOrEqual(minPercentageDifference, 0.4) {
                    self.text.setText(to: "C")
                } else {
                    self.text.setText(to: "NONE")
                }
                

                if true {
                    let width = 2.0*radius*(1.0 + 0.25)
                    let circleView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: width))
                    circleView.center = circleCenter
                    circleView.backgroundColor = UIColor.red.withAlphaComponent(0.15)
                    circleView.layer.cornerRadius = circleView.frame.width / 2
                    self.image.clearSubviewsAndLayers()
                    self.image.addSubview(LimeView(circleView))
                }
                
                if true {
                    let width = 2.0*radius*(1.0 - 0.4)
                    let circleView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: width))
                    circleView.center = circleCenter
                    circleView.backgroundColor = UIColor.red.withAlphaComponent(0.15)
                    circleView.layer.cornerRadius = circleView.frame.width / 2
                    self.image.addSubview(LimeView(circleView))
                }
                
                
                
                /*
                
                
                
                let positions: [CGPoint] = joints.compactMap { $0.position }
                guard positions.count == joints.count else { return }
                
                guard let index2Position = hand1.indexPIP.position,
                      let index3Position = hand1.indexDIP.position,
                      let thumb2Position = hand1.thumbMP.position,
                      let thumb3Position = hand1.thumbIP.position else {
                    return
                }
                
                // Get the average point between index 2 and 3
                let circleTop = index2Position.midpoint(relativeTo: index3Position)
                
                // Get thumb 2
                let circleBottom = thumb2Position.midpoint(relativeTo: thumb3Position)
                
                // Find the centre between the two points
                let circleCenter = circleTop.midpoint(relativeTo: circleBottom)
                
                let distances = positions.map({ $0.length(to: circleCenter) })
//                print("DISTANCES: \(distances)")
                let radius = (distances.reduce(0.0) { $0 + $1 })/Double(distances.count)
//                print("RADIUS: \(radius)")
//
//                print("RADIUS: \(radius)")
//                print("MAX: \(distances.max()!)")
//                print("MIN: \(distances.min()!)")
//                print("PER MAX: \(100.0*distances.max()!/radius - 100.0)") // 30% limit
//                print("PER MIN: \(100.0 - 100.0*distances.min()!/radius)") // 40% limit
                
                let maxDistance = distances.max()!
                let minDistance = distances.min()!
                let maxPercentageDifference = maxDistance/radius - 1.0
                let minPercentageDifference = 1.0 - minDistance/radius
                
                if isLessOrEqual(maxPercentageDifference, 0.26) && isLessOrEqual(minPercentageDifference, 0.4) {
                    self.text.setText(to: "C")
                } else {
                    self.text.setText(to: "NONE")
                }
                
                if true {
                    let top  = JointPosition(name: "")
                    top.position = circleTop
                    let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 16.0, height: 16.0))
                    circleView.center = top.getDenormalisedPosition(for: self.jointPositionsOverlay.view)!
//                    print("TOP: \(circleView.center.toString())")
                    circleView.backgroundColor = UIColor.blue
                    circleView.layer.cornerRadius = circleView.frame.width / 2
                    self.image.clearSubviewsAndLayers()
                    self.image.addSubview(LimeView(circleView))
                }
                
                if true {
                    let top  = JointPosition(name: "")
                    top.position = circleBottom
                    let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 16.0, height: 16.0))
                    circleView.center = top.getDenormalisedPosition(for: self.jointPositionsOverlay.view)!
//                    print("BOTTOM: \(circleView.center.toString())")
                    circleView.backgroundColor = UIColor.blue
                    circleView.layer.cornerRadius = circleView.frame.width / 2
                    self.image.addSubview(LimeView(circleView))
                }
                
                if true {
                    let top  = JointPosition(name: "")
                    top.position = circleCenter
                    let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 16.0, height: 16.0))
                    circleView.center = top.getDenormalisedPosition(for: self.jointPositionsOverlay.view)!
                    circleView.backgroundColor = UIColor.blue
                    circleView.layer.cornerRadius = circleView.frame.width / 2
                    self.image.addSubview(LimeView(circleView))
                }
                
                let denormalisedPositions = joints.map({ $0.getDenormalisedPosition(for: self.jointPositionsOverlay.view)! })
                for dpos in denormalisedPositions {
                    let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 28.0, height: 28.0))
                    circleView.center = dpos
                    circleView.backgroundColor = UIColor.blue
                    circleView.layer.cornerRadius = circleView.frame.width / 2
                    self.image.addSubview(LimeView(circleView))
                }
                let centerJoint = JointPosition(name: "")
                centerJoint.position = circleCenter
                let denormalisedCenter = centerJoint.getDenormalisedPosition(for: self.jointPositionsOverlay.view)!
                let denormalisedDistances = denormalisedPositions.map({ $0.length(to: denormalisedCenter) })
                let denormalisedRadius = (denormalisedDistances.reduce(0.0) { $0 + $1 })/Double(denormalisedDistances.count)
                
                let denormalisedMaxDistance = denormalisedDistances.max()!
                let denormalisedMinDistance = denormalisedDistances.min()!
                let denormalisedMaxPercentageDifference = denormalisedMaxDistance/denormalisedRadius - 1.0
                let denormalisedMinPercentageDifference = 1.0 - denormalisedMinDistance/denormalisedRadius
                
                print("\(maxPercentageDifference.rounded(decimalPlaces: 4)) | \(denormalisedMaxPercentageDifference.rounded(decimalPlaces: 4))")
                
                let top = JointPosition(name: "")
                top.position = circleTop
                let bottom = JointPosition(name: "")
                bottom.position = circleBottom
                
                
                let test = JointPosition(name: "")
                test.position = circleCenter
                let test2 = JointPosition(name: "")
                test2.position = circleCenter + CGPoint(x: radius, y: 0.0)
//                let width = 2.0*test.getDenormalisedPosition(for: self.jointPositionsOverlay.view)!.length(to: test2.getDenormalisedPosition(for: self.jointPositionsOverlay.view)!)
//                let width = top.getDenormalisedPosition(for: self.jointPositionsOverlay.view)!.length(to: bottom.getDenormalisedPosition(for: self.jointPositionsOverlay.view)!)
                let width = denormalisedRadius*2
                let circleView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: width))
                circleView.center = test.getDenormalisedPosition(for: self.jointPositionsOverlay.view)!
                circleView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
                circleView.layer.cornerRadius = circleView.frame.width / 2
//                self.image.clearSubviewsAndLayers()
                self.image.addSubview(LimeView(circleView))
                
                if true {
                    let test = JointPosition(name: "")
                    test.position = circleCenter
                    let test2 = JointPosition(name: "")
                    test2.position = circleCenter + CGPoint(x: radius, y: 0.0)
                    let width = 2.0*test.getDenormalisedPosition(for: self.jointPositionsOverlay.view)!.length(to: test2.getDenormalisedPosition(for: self.jointPositionsOverlay.view)!)
                    let circleView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: width))
                    circleView.center = test.getDenormalisedPosition(for: self.jointPositionsOverlay.view)!
                    circleView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
                    circleView.layer.cornerRadius = circleView.frame.width / 2
                    self.image.addSubview(LimeView(circleView))
                }
                
                return
                 */
            }
            
            if outcome.handDetections.count == 2 {
                let hand1 = outcome.handDetections[0]
                let hand2 = outcome.handDetections[1]
                if let indexTip = hand1.index4.position, let thumbTip = hand2.thumb4.position {
                    let distance = indexTip.length(to: thumbTip)
                    if isLessOrEqual(distance, 0.025) {
                        self.text.setText(to: "A")
                    }
                }
                if let indexTip = hand2.index4.position, let thumbTip = hand1.thumb4.position {
                    let distance = indexTip.length(to: thumbTip)
                    if isLessOrEqual(distance, 0.025) {
                        self.text.setText(to: "A")
                    }
                }
                if let indexTip = hand1.index4.position, let otherIndexTip = hand2.index4.position {
                    let distance = indexTip.length(to: otherIndexTip)
                    if isLessOrEqual(distance, 0.025) {
                        self.text.setText(to: "E")
                    }
                }
                if let indexTip = hand1.index4.position, let middleTip = hand2.middle4.position {
                    let distance = indexTip.length(to: middleTip)
                    if isLessOrEqual(distance, 0.025) {
                        self.text.setText(to: "I")
                    }
                }
                if let indexTip = hand2.index4.position, let middleTip = hand1.middle4.position {
                    let distance = indexTip.length(to: middleTip)
                    if isLessOrEqual(distance, 0.025) {
                        self.text.setText(to: "I")
                    }
                }
                if let indexTip = hand1.index4.position, let ringTip = hand2.ring4.position {
                    let distance = indexTip.length(to: ringTip)
                    if isLessOrEqual(distance, 0.025) {
                        self.text.setText(to: "O")
                    }
                }
                if let indexTip = hand2.index4.position, let ringTip = hand1.ring4.position {
                    let distance = indexTip.length(to: ringTip)
                    if isLessOrEqual(distance, 0.025) {
                        self.text.setText(to: "O")
                    }
                }
                if let indexTip = hand1.index4.position, let littleTip = hand2.little4.position {
                    let distance = indexTip.length(to: littleTip)
                    if isLessOrEqual(distance, 0.025) {
                        self.text.setText(to: "U")
                    }
                }
                if let indexTip = hand2.index4.position, let littleTip = hand1.little4.position {
                    let distance = indexTip.length(to: littleTip)
                    if isLessOrEqual(distance, 0.025) {
                        self.text.setText(to: "U")
                    }
                }
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
        self.handOverlayView.setFrame(to: overlayFrame)
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
