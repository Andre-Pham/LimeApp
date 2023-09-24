//
//  HandOverlayView.swift
//  Lime
//
//  Created by Andre Pham on 23/9/2023.
//

import Foundation
import CoreGraphics
import UIKit

class HandOverlayView: LimeUIView {
    
    /// The line width
    private static let WIDTH = 4.0
    /// The smoothing factor, range: [0, 1]
    /// A smaller value means it takes more of the current position (0.0 means it ignores the previous position)
    /// A large value means it takes more of the previous position (1.0 means it ignores the current position)
    private static let SMOOTHING_FACTOR = 0.4
    /// The number of previous hand detections to smooth from
    private static let SMOOTH_FROM_PREVIOUS = 8
    
    private var previousHandDetections = [HandDetectionOutcome]()
    private let overlay = LimeImage()
    public var view: UIView {
        return self.overlay.view
    }
    
    override init() {
        super.init()
        self.overlay.setBackgroundColor(to: UIColor.black.withAlphaComponent(0.1))
    }
    
    func draw(for handDetectionOutcome: HandDetectionOutcome) {
        self.overlay.clearSubviewsAndLayers()
        
        self.previousHandDetections.append(handDetectionOutcome)
        
        UIGraphicsBeginImageContextWithOptions(self.overlay.frame.size, false, 1.0)
        defer {
            UIGraphicsEndImageContext()
        }
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(Self.WIDTH)
            context.setLineCap(.round)
            
            var smoothedDetections = self.previousHandDetections.first!
            if self.previousHandDetections.count > 1 {
                for handDetectionIndex in 1..<self.previousHandDetections.endIndex {
                    let handDetection = self.previousHandDetections[handDetectionIndex]
                    smoothedDetections = self.interpolateDetections(previous: smoothedDetections, current: handDetection)
                }
            }
            
            for handDetection in smoothedDetections.handDetections {
                self.drawHandDetection(context, handDetection)
            }
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                self.overlay.setImage(image)
            }
        }
        
        if self.previousHandDetections.count > Self.SMOOTH_FROM_PREVIOUS {
            self.previousHandDetections.removeUntil(capacity: Self.SMOOTH_FROM_PREVIOUS, takeFromEnd: false)
        }
    }
    
    private func interpolateDetections(previous: HandDetectionOutcome, current: HandDetectionOutcome) -> HandDetectionOutcome {
        let smoothedOutcome = HandDetectionOutcome(frameSize: current.frameSize)
        previous.arrangeHandDetections(matching: current)
        for handDetectionIndex in current.handDetections.indices {
            guard previous.handDetections.count >= handDetectionIndex + 1 else {
                continue
            }
            smoothedOutcome.addHandDetection(
                current.handDetections[handDetectionIndex].interpolate(
                    with: previous.handDetections[handDetectionIndex], factor: Self.SMOOTHING_FACTOR
                )
            )
        }
        return smoothedOutcome.handDetections.isEmpty ? current : smoothedOutcome
    }
    
    private func drawHandDetection(_ context: CGContext, _ hand: HandDetection) {
        for fingerJointArray in [hand.thumbPositions, hand.indexPositions, hand.middlePositions, hand.ringPositions, hand.littlePositions] {
            for jointIndex in fingerJointArray.startIndex..<fingerJointArray.endIndex - 1 {
                self.drawLine(context, fingerJointArray[jointIndex], fingerJointArray[jointIndex + 1])
            }
        }
        self.drawLine(context, hand.wrist, hand.thumb1)
        self.drawLine(context, hand.index1, hand.middle1)
        self.drawLine(context, hand.middle1, hand.ring1)
        self.drawLine(context, hand.ring1, hand.little1)
        self.drawLine(context, hand.wrist, hand.index1)
        self.drawLine(context, hand.wrist, hand.little1)
    }
    
    private func drawLine(_ context: CGContext, _ joint1: JointPosition, _ joint2: JointPosition) {
        guard let startPoint = joint1.getDenormalisedPosition(for: self.view),
              let endPoint = joint2.getDenormalisedPosition(for: self.view) else {
            return
        }
        let averageConfidence = ((joint1.confidence ?? 0.0) + (joint2.confidence ?? 0.0))/2.0
        context.setStrokeColor(UIColor.white.withAlphaComponent(CGFloat(pow(averageConfidence, 6)/1.5)).cgColor)
        context.move(to: startPoint)
        context.addLine(to: endPoint)
        context.drawPath(using: .stroke)
    }
    
}
