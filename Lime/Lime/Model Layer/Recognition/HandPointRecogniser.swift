//
//  HandPointRecogniser.swift
//  Lime
//
//  Created by Andre Pham on 7/5/2023.
//

import Foundation
import Vision
import SceneKit

class HandPointRecogniser {
    
    func getHandPosition(observation: VNHumanHandPoseObservation) -> JointPositions {
        assert(!Thread.isMainThread, "Recognition should be made off the main thread")
        let jointPositions = JointPositions()
        guard let recognisedPoints = try? observation.recognizedPoints(.all) else {
            return jointPositions
        }
        for point in recognisedPoints {
            let jointPosition = jointPositions.retrievePosition(from: point.key)
            jointPosition.position = CGPoint(x: point.value.location.x, y: point.value.location.y)
            jointPosition.confidence = point.value.confidence.magnitude
        }
        return jointPositions
    }
    
}
