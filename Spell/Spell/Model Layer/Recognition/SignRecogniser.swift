//
//  SignRecogniser.swift
//  Spell
//
//  Created by Andre Pham on 7/5/2023.
//

import Foundation
import UIKit
import AVFoundation
import Vision
import SceneKit

class SignRecogniser {
    
    private static let CONFIDENCE_THRESHOLD = 0.9
    
    private let model = try? ASLDemoClassifier_2(configuration: MLModelConfiguration())
    private let handPointRecogniser = HandPointRecogniser()
    private let operations = OperationQueue()
    public weak var signDelegate: SignDelegate?
    
    init() {
        self.operations.maxConcurrentOperationCount = 5 // Magic number
    }
    
    func makePrediction(on frame: CGImage) {
        // Run on non-UI related background thread
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            // Use operations to manage number of concurrent processes
            // Otherwise main thread can throttle
            self.operations.addOperation {
                self.process(frame: frame)
            }
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
        
        let predictionOutcome = PredictionOutcome()
        guard let handPoses = handPoseRequest.results, !handPoses.isEmpty else {
            self.delegateOutcome(predictionOutcome)
            return
        }
        assert(handPoses.count <= 2, "The request should only ever process two hands (even if more are in frame)")
        
        // Delegate outcomes
        for (handIndex, observation) in handPoses.enumerated() {
            guard let keyPointsMultiArray = try? observation.keypointsMultiArray() else {
                continue
            }
            let prediction = try? self.model?.prediction(poses: keyPointsMultiArray)
            if let label = prediction?.label, let confidence = prediction?.labelProbabilities[label] {
                guard isGreaterOrEqual(confidence, Self.CONFIDENCE_THRESHOLD) else {
                    continue
                }
                var labelFound = false
                for labelCase in Label.allCases {
                    if label == labelCase.rawValue {
                        predictionOutcome.setHandOutcome(hand: handIndex, label: labelCase)
                        labelFound = true
                        break
                    }
                }
                assert(labelFound, "Prediction found \(label) however no matching Label case was found")
            }
        }
        self.delegateOutcome(predictionOutcome)
        
        // Delegate positions
        for (handIndex, observation) in handPoses.enumerated() {
            let positions = self.handPointRecogniser.getHandPosition(observation: observation)
            predictionOutcome.setHandPosition(hand: handIndex, positions: positions)
        }
        self.delegatePositions(predictionOutcome)
    }
    
    private func delegateOutcome(_ outcome: PredictionOutcome) {
        // Jump back to main thread
        DispatchQueue.main.async {
            self.signDelegate?.onPrediction(outcome: outcome)
        }
    }
    
    private func delegatePositions(_ outcome: PredictionOutcome) {
        // Jump back to main thread
        DispatchQueue.main.async {
            self.signDelegate?.onPredictionPositions(outcome: outcome)
        }
    }
    
}
