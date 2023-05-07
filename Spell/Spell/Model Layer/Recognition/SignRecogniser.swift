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
    public weak var signDelegate: SignDelegate?
    
    func makePrediction(on frame: CGImage) {
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
        
        guard let handPoses = handPoseRequest.results, !handPoses.isEmpty,
              let keyPointsMultiArray = try? handPoses.first!.keypointsMultiArray() else {
            self.delegateOutcome(.none)
            return
        }
        
        let observation = handPoses.first!
        let prediction = try? self.model?.prediction(poses: keyPointsMultiArray)
        if let label = prediction?.label, let confidence = prediction?.labelProbabilities[label] {
            guard isGreaterOrEqual(confidence, Self.CONFIDENCE_THRESHOLD) else {
                self.delegateOutcome(.none)
                self.delegatePositions(.none, observation: observation)
                return
            }
            for labelCase in Label.allCases {
                if label == labelCase.rawValue {
                    self.delegateOutcome(labelCase)
                    self.delegatePositions(labelCase, observation: observation)
                    return
                }
            }
            assertionFailure("Prediction found \(label) however no matching Label case was found")
        }
        
        assertionFailure("Label and/or confidence could not be read")
    }
    
    private func delegateOutcome(_ outcome: Label) {
        // Jump back to main thread
        DispatchQueue.main.async {
            self.signDelegate?.onPrediction(outcome: outcome)
        }
    }
    
    private func delegatePositions(_ outcome: Label, observation: VNHumanHandPoseObservation) {
        let positions = self.handPointRecogniser.getHandPosition(observation: observation)
        // Jump back to main thread
        DispatchQueue.main.async {
            self.signDelegate?.onPredictionPositions(outcome: outcome, positions: positions)
        }
    }
    
}
