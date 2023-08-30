//
//  JointPositions.swift
//  Lime
//
//  Created by Andre Pham on 7/5/2023.
//

import Foundation
import Vision

class JointPositions {
    
    // MARK: - Wrist Properties
    
    private(set) var wrist = JointPosition(name: "wrist")
    
    // MARK: - Thumb Properties
    
    private(set) var thumbCMC = JointPosition(name: "thumb1")
    private(set) var thumbMP = JointPosition(name: "thumb2")
    private(set) var thumbIP = JointPosition(name: "thumb2")
    private(set) var thumbTip = JointPosition(name: "thumb4")
    public var thumbPositions: [JointPosition] {
        return [self.thumbCMC, self.thumbMP, self.thumbIP, self.thumbTip]
    }
    
    // MARK: - Index Properties
    
    private(set) var indexMCP = JointPosition(name: "index1")
    private(set) var indexPIP = JointPosition(name: "index2")
    private(set) var indexDIP = JointPosition(name: "index3")
    private(set) var indexTip = JointPosition(name: "index4")
    public var indexPositions: [JointPosition] {
        return [self.indexMCP, self.indexPIP, self.indexDIP, self.indexTip]
    }
    
    // MARK: - Middle Properties
    
    private(set) var middleMCP = JointPosition(name: "middle1")
    private(set) var middlePIP = JointPosition(name: "middle2")
    private(set) var middleDIP = JointPosition(name: "middle3")
    private(set) var middleTip = JointPosition(name: "middle4")
    public var middlePositions: [JointPosition] {
        return [self.middleMCP, self.middlePIP, self.middleDIP, self.middleTip]
    }
    
    // MARK: - Ring Properties
    
    private(set) var ringMCP = JointPosition(name: "ring1")
    private(set) var ringPIP = JointPosition(name: "ring2")
    private(set) var ringDIP = JointPosition(name: "ring3")
    private(set) var ringTip = JointPosition(name: "ring4")
    public var ringPositions: [JointPosition] {
        return [self.ringMCP, self.ringPIP, self.ringDIP, self.ringTip]
    }
    
    // MARK: - Little Properties
    
    private(set) var littleMCP = JointPosition(name: "little1")
    private(set) var littlePIP = JointPosition(name: "little2")
    private(set) var littleDIP = JointPosition(name: "little3")
    private(set) var littleTip = JointPosition(name: "little4")
    public var littlePositions: [JointPosition] {
        return [self.littleMCP, self.littlePIP, self.littleDIP, self.littleTip]
    }
    
    // MARK: - All Properties
    
    var allPositions: [JointPosition] {
        return [self.wrist] + self.thumbPositions + self.indexPositions + self.middlePositions + self.ringPositions + self.littlePositions
    }
    
    func retrievePosition(from joint: VNHumanHandPoseObservation.JointName) -> JointPosition {
        switch joint {
        case .wrist: return self.wrist
        case .thumbCMC: return self.thumbCMC
        case .thumbMP: return self.thumbMP
        case .thumbIP: return self.thumbIP
        case .thumbTip: return self.thumbTip
        case .indexMCP: return self.indexMCP
        case .indexPIP: return self.indexPIP
        case .indexDIP: return self.indexDIP
        case .indexTip: return self.indexTip
        case .middleMCP: return self.middleMCP
        case .middlePIP: return self.middlePIP
        case .middleDIP: return self.middleDIP
        case .middleTip: return self.middleTip
        case .ringMCP: return self.ringMCP
        case .ringPIP: return self.ringPIP
        case .ringDIP: return self.ringDIP
        case .ringTip: return self.ringTip
        case .littleMCP: return self.littleMCP
        case .littlePIP: return self.littlePIP
        case .littleDIP: return self.littleDIP
        case .littleTip: return self.littleTip
        default:
            assertionFailure("Missing joint causes switch to not be exhaustive")
            return JointPosition(name: "")
        }
    }
    
}
