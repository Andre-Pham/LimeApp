//
//  HandDetector.swift
//  Lime
//
//  Created by Andre Pham on 21/9/2023.
//

import Foundation
import UIKit
import Vision

class HandDetector {
    
    private static let MAX_THREADS = 3
    
    private var activeThreads = 0
    public weak var handDetectionDelegate: HandDetectionDelegate?
    
    init() { }
    
    func makePrediction(on frame: CGImage) {
        guard self.activeThreads < Self.MAX_THREADS else {
            return
        }
        self.activeThreads += 1
        // Run on non-UI related background thread
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            self.process(frame: frame)
        }
    }
    
    private func process(frame: CGImage) {
        assert(!Thread.isMainThread, "Predictions should be made off the main thread")
        
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 2
        handPoseRequest.revision = VNDetectHumanHandPoseRequestRevision1
        
        let handler = VNImageRequestHandler(cgImage: frame, orientation: .up)
        do {
            try handler.perform([handPoseRequest])
        } catch {
            assertionFailure("Handler failed with error: \(error)")
        }
        
        let handDetectionOutcome = HandDetectionOutcome()
        guard let handPoses = handPoseRequest.results, !handPoses.isEmpty else {
            self.delegateOutcome(handDetectionOutcome)
            return
        }
        for handPose in handPoses {
            let handDetection = self.getHandDetection(from: handPose)
            handDetectionOutcome.addHandDetection(handDetection)
        }
        self.delegateOutcome(handDetectionOutcome)
    }
    
    func getHandDetection(from observation: VNHumanHandPoseObservation) -> HandDetection {
        assert(!Thread.isMainThread, "Recognition should be made off the main thread")
        let handDetection = HandDetection()
        guard let recognisedPoints = try? observation.recognizedPoints(.all) else {
            return handDetection
        }
        for point in recognisedPoints {
            let jointPosition = handDetection.retrievePosition(from: point.key)
            jointPosition.position = CGPoint(x: point.value.location.x, y: point.value.location.y)
            jointPosition.confidence = point.value.confidence.magnitude
        }
        return handDetection
    }
    
    private func delegateOutcome(_ outcome: HandDetectionOutcome) {
        // Jump back to main thread
        DispatchQueue.main.async {
            self.activeThreads -= 1
            self.handDetectionDelegate?.onHandDetection(outcome: outcome)
        }
    }
    
}

