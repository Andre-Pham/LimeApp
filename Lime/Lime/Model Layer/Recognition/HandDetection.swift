//
//  HandDetection.swift
//  Lime
//
//  Created by Andre Pham on 21/9/2023.
//

import Foundation
import Vision

class HandDetection {
    
    public let id = UUID()
    
    // MARK: - Wrist Properties
    
    private(set) var wrist = JointPosition(name: "wrist")
    
    // MARK: - Thumb Properties
    
    private(set) var thumb1 = JointPosition(name: "thumb1")
    private(set) var thumb2 = JointPosition(name: "thumb2")
    private(set) var thumb3 = JointPosition(name: "thumb3")
    private(set) var thumb4 = JointPosition(name: "thumb4")
    public var thumbPositions: [JointPosition] {
        return [self.thumb1, self.thumb2, self.thumb3, self.thumb4]
    }
    
    // MARK: - Index Properties
    
    private(set) var index1 = JointPosition(name: "index1")
    private(set) var index2 = JointPosition(name: "index2")
    private(set) var index3 = JointPosition(name: "index3")
    private(set) var index4 = JointPosition(name: "index4")
    public var indexPositions: [JointPosition] {
        return [self.index1, self.index2, self.index3, self.index4]
    }
    
    // MARK: - Middle Properties
    
    private(set) var middle1 = JointPosition(name: "middle1")
    private(set) var middle2 = JointPosition(name: "middle2")
    private(set) var middle3 = JointPosition(name: "middle3")
    private(set) var middle4 = JointPosition(name: "middle4")
    public var middlePositions: [JointPosition] {
        return [self.middle1, self.middle2, self.middle3, self.middle4]
    }
    
    // MARK: - Ring Properties
    
    private(set) var ring1 = JointPosition(name: "ring1")
    private(set) var ring2 = JointPosition(name: "ring2")
    private(set) var ring3 = JointPosition(name: "ring3")
    private(set) var ring4 = JointPosition(name: "ring4")
    public var ringPositions: [JointPosition] {
        return [self.ring1, self.ring2, self.ring3, self.ring4]
    }
    
    // MARK: - Little Properties
    
    private(set) var little1 = JointPosition(name: "little1")
    private(set) var little2 = JointPosition(name: "little2")
    private(set) var little3 = JointPosition(name: "little3")
    private(set) var little4 = JointPosition(name: "little4")
    public var littlePositions: [JointPosition] {
        return [self.little1, self.little2, self.little3, self.little4]
    }
    
    // MARK: - All Properties
    
    public var allPositions: [JointPosition] {
        return [self.wrist] + self.thumbPositions + self.indexPositions + self.middlePositions + self.ringPositions + self.littlePositions
    }
    
    public var averageConfidence: Double {
        return Double((self.allPositions.reduce(0.0) { $0 + ($1.confidence ?? 0.0) })/Float(self.allPositions.count))
    }
    
    func retrievePosition(from joint: VNHumanHandPoseObservation.JointName) -> JointPosition {
        switch joint {
        case .wrist: return self.wrist
        case .thumbCMC: return self.thumb1
        case .thumbMP: return self.thumb2
        case .thumbIP: return self.thumb3
        case .thumbTip: return self.thumb4
        case .indexMCP: return self.index1
        case .indexPIP: return self.index2
        case .indexDIP: return self.index3
        case .indexTip: return self.index4
        case .middleMCP: return self.middle1
        case .middlePIP: return self.middle2
        case .middleDIP: return self.middle3
        case .middleTip: return self.middle4
        case .ringMCP: return self.ring1
        case .ringPIP: return self.ring2
        case .ringDIP: return self.ring3
        case .ringTip: return self.ring4
        case .littleMCP: return self.little1
        case .littlePIP: return self.little2
        case .littleDIP: return self.little3
        case .littleTip: return self.little4
        default:
            assertionFailure("Missing joint causes switch to not be exhaustive")
            return JointPosition(name: "")
        }
    }
    
    func interpolate(with previous: HandDetection, factor: Double) -> HandDetection {
        let interpolatedHand = HandDetection()
        for jointIndex in self.allPositions.indices {
            let previousJoint = previous.allPositions[jointIndex]
            let currentJoint = self.allPositions[jointIndex]
            let interpolatedJoint = currentJoint.interpolate(with: previousJoint, factor: factor)
            interpolatedHand.allPositions[jointIndex].position = interpolatedJoint.position
            interpolatedHand.allPositions[jointIndex].confidence = interpolatedJoint.confidence
        }
        return interpolatedHand
    }
    
    func accumulatedDistance(to otherHand: HandDetection) -> Double {
        var totalDistance = 0.0
        for jointIndex in self.allPositions.indices {
            let joint1 = self.allPositions[jointIndex]
            let joint2 = otherHand.allPositions[jointIndex]
            if let position1 = joint1.position, let position2 = joint2.position {
                let dx = position1.x - position2.x
                let dy = position1.y - position2.y
                totalDistance += sqrt(dx*dx + dy*dy)
            }
        }
        return totalDistance
    }
    
    func getDenormalizedPalmLength(frameSize: CGSize) -> Double {
        // The distance from the wrist to the little finger
        // It's an extremely consistent length regardless of which fingers are curled, the hand direction, etc.
        guard let wristPosition = self.wrist.getDenormalizedPosition(for: frameSize),
              let littlePosition = self.little1.getDenormalizedPosition(for: frameSize) else {
            assertionFailure("We shouldn't be calling the size rating if there's insufficient positions defined")
            return 0.0
        }
        return wristPosition.length(to: littlePosition)
    }
    
    func getDenormalizedPalmToTipLength(frameSize: CGSize) -> Double {
        guard let wristPosition = self.wrist.getDenormalizedPosition(for: frameSize),
              let middlePosition = self.middle4.getDenormalizedPosition(for: frameSize) else {
            assertionFailure("We shouldn't be calling the size rating if there's insufficient positions defined")
            return 0.0
        }
        if let middle1 = self.middle1.getDenormalizedPosition(for: frameSize),
           let middle2 = self.middle2.getDenormalizedPosition(for: frameSize),
           let middle3 = self.middle3.getDenormalizedPosition(for: frameSize) {
            return (
                wristPosition.length(to: middle1) +
                middle1.length(to: middle2) +
                middle2.length(to: middle3) +
                middle3.length(to: middlePosition)
            )
        }
        return wristPosition.length(to: middlePosition)
    }
    
    func getPalmLength() -> Double {
        guard let wristPosition = self.wrist.position,
              let littlePosition = self.little1.position else {
            assertionFailure("We shouldn't be calling the size rating if there's insufficient positions defined")
            return 0.0
        }
        return wristPosition.length(to: littlePosition)
    }
    
    func getPalmToTipLength() -> Double {
        guard let wristPosition = self.wrist.position,
              let middlePosition = self.middle4.position else {
            assertionFailure("We shouldn't be calling the size rating if there's insufficient positions defined")
            return 0.0
        }
        if let middle1 = self.middle1.position,
           let middle2 = self.middle2.position,
           let middle3 = self.middle3.position {
            return (
                wristPosition.length(to: middle1) +
                middle1.length(to: middle2) +
                middle2.length(to: middle3) +
                middle3.length(to: middlePosition)
            )
        }
        return wristPosition.length(to: middlePosition)
    }
    
}
