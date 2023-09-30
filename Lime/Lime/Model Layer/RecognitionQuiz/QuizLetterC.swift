//
//  QuizLetterC.swift
//  Lime
//
//  Created by Andre Pham on 23/9/2023.
//

import Foundation

class QuizLetterC: QuizLetter {
    
    public let letter: Character = "C"
    
    func acceptAnswer(answer: HandDetectionOutcome) -> QuizAnswerStatus {
        // Here's the idea.
        // Creating a "C" with your index and thumb creates a close-to-circle if you were to plot all the points.
        // So we re-create this circle shape by calculating what the circle center and radius would be.
        // If all the joint positions are somewhat near this circle outline, we can be pretty confident the finger is making a circle shape.
        // If we're pretty confident we're making a circle shape, we can assume the user is making a C shape.
        // We check every hand.
        for hand in answer.handDetections {
            let relevantJoints = [
                hand.index1, hand.index2, hand.index3, hand.index4,
                hand.thumb2, hand.thumb3, hand.thumb4
            ]
            // Make sure the points are denormalized - otherwise two points on other ends of the rectangle picture are effectively squished together in the normalized version (seeing that the width and height are effectively 1.0 and 1.0)
            let positions: [CGPoint] = relevantJoints.compactMap({ $0.getDenormalizedPosition(for: answer.frameSize) })
            guard positions.count == relevantJoints.count else {
                continue
            }
            let index2Position = positions[1]
            let index3Position = positions[2]
            let thumb2Position = positions[4]
            let thumb3Position = positions[5]
            // Identify the circle center
            let circleTop = index2Position.midpoint(relativeTo: index3Position)
            let circleBottom = thumb2Position.midpoint(relativeTo: thumb3Position)
            let circleCenter = circleTop.midpoint(relativeTo: circleBottom)
            // Find the distances from every relevant joint to the circle center
            let distances = positions.map({ $0.length(to: circleCenter) })
            // Then use the average of those distances to find an approximate radius
            let radius = (distances.reduce(0.0) { $0 + $1 })/Double(distances.count)
            // We make sure every point is within the boundary - there's only a need to check the max and min
            let maxDistance = distances.max()!
            let minDistance = distances.min()!
            let maxPercentageDifference = maxDistance/radius - 1.0
            let minPercentageDifference = 1.0 - minDistance/radius
            // Imagine two circles - one with a radius 25% larger than initial circle found, and one with a radius 40% smaller
            // If every point lies between these two circles, they're within the circle boundary
            if isLessOrEqual(maxPercentageDifference, 0.25) && isLessOrEqual(minPercentageDifference, 0.4) {
                return .correct
            }
        }
        return .incorrect
    }
    
}
