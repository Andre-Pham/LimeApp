//
//  HandDetectionOutcome.swift
//  Lime
//
//  Created by Andre Pham on 21/9/2023.
//

import Foundation

class HandDetectionOutcome {
    
    private(set) var handDetections = [HandDetection]()
    
    init() { }
    
    func addHandDetection(_ handDetection: HandDetection) {
        self.handDetections.append(handDetection)
    }
    
    func arrangeHandDetections(matching outcome: HandDetectionOutcome) {
        var orderedDetections = [HandDetection]()

        for otherHand in outcome.handDetections {
            let bestMatch = self.handDetections.min { (hand1, hand2) -> Bool in
                let distance1 = hand1.accumulatedDistance(to: otherHand)
                let distance2 = hand2.accumulatedDistance(to: otherHand)
                return distance1 < distance2
            }
            if let bestMatch = bestMatch {
                orderedDetections.append(bestMatch)
                self.handDetections.removeAll(where: { $0.id == bestMatch.id })
            }
        }

        self.handDetections = orderedDetections
    }
    
}
