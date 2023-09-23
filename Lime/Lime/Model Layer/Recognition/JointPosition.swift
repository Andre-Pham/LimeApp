//
//  JointPosition.swift
//  Lime
//
//  Created by Andre Pham on 7/5/2023.
//

import Foundation
import SceneKit
import Vision

class JointPosition {
    
    public let name: String
    public var position: CGPoint? = nil
    public var confidence: Float? = nil
    
    init(name: String) {
        self.name = name
    }
    
    func getDenormalisedPosition(for view: UIView) -> CGPoint? {
        return self.getDenormalisedPosition(viewWidth: view.bounds.width, viewHeight: view.bounds.height)
    }
    
    func getDenormalisedPosition(viewWidth: Double, viewHeight: Double) -> CGPoint? {
        if self.position == nil { return nil }
        return VNImagePointForNormalizedPoint(
            CGPoint(
                x: self.position!.x,
                y: 1 - self.position!.y
            ),
            Int(viewWidth),
            Int(viewHeight)
        )
    }
    
    func interpolate(with previous: JointPosition, factor: Double) -> JointPosition {
        let interpolatedJoint = JointPosition(name: self.name)
        interpolatedJoint.confidence = self.confidence
        if let currentPosition = self.position,
            let previousPosition = previous.position {
            let interpolatedX = currentPosition.x * (1.0 - factor) + previousPosition.x * factor
            let interpolatedY = currentPosition.y * (1.0 - factor) + previousPosition.y * factor
            interpolatedJoint.position = CGPoint(x: interpolatedX, y: interpolatedY)
        }
        return interpolatedJoint
    }
    
}
