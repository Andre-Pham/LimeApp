//
//  JointPosition.swift
//  Spell
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
    
}
