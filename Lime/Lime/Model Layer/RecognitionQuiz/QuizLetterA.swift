//
//  QuizLetterA.swift
//  Lime
//
//  Created by Andre Pham on 23/9/2023.
//

import Foundation

class QuizLetterA: QuizLetter {
    
    public let letter: Character = "A"
    
    func acceptAnswer(answer: HandDetectionOutcome) -> QuizAnswerStatus {
        guard answer.handDetections.count == 2 else {
            return .incorrect
        }
        let hand1 = answer.handDetections[0]
        let hand2 = answer.handDetections[1]
        let palmLength = (
            hand1.getDenormalizedPalmLength(frameSize: answer.frameSize) +
            hand2.getDenormalizedPalmLength(frameSize: answer.frameSize)
        )/2.0
        
        // First check if any non thumb/index fingers are touching - if so, it's incorrect
        // This stops the user just smushing their hand together or performing a weird sign by touching many fingers
        let hand1OtherFingerTips = [hand1.middle4, hand1.ring4, hand1.little4]
        let hand2OtherFingerTips = [hand2.middle4, hand2.ring4, hand2.little4]
        let hand1OtherPositions = hand1OtherFingerTips.compactMap({ $0.getDenormalizedPosition(for: answer.frameSize) })
        let hand2OtherPositions = hand2OtherFingerTips.compactMap({ $0.getDenormalizedPosition(for: answer.frameSize) })
        guard (hand1OtherPositions.count == hand1OtherFingerTips.count &&
               hand2OtherPositions.count == hand2OtherFingerTips.count
        ) else {
            return .incorrect
        }
        for position1 in hand1OtherPositions {
            for position2 in hand2OtherPositions {
                if isLessOrEqual(
                    position1.length(to: position2)/palmLength,
                    Self.CLOSE_THRESHOLD
                ) {
                    return .incorrect
                }
            }
        }
        
        guard let indexHand1 = hand1.index4.getDenormalizedPosition(for: answer.frameSize),
              let indexHand2 = hand2.index4.getDenormalizedPosition(for: answer.frameSize),
              let thumbHand1 = hand1.thumb4.getDenormalizedPosition(for: answer.frameSize),
              let thumbHand2 = hand2.thumb4.getDenormalizedPosition(for: answer.frameSize) else {
            return .incorrect
        }
        
        // Next if the index is touching the other index, or the thumb is touching the other thumb, it's also incorrect
        if isLessOrEqual(indexHand1.length(to: indexHand2)/palmLength, Self.CLOSE_THRESHOLD) {
            return .incorrect
        }
        if isLessOrEqual(thumbHand1.length(to: thumbHand2)/palmLength, Self.CLOSE_THRESHOLD) {
            return .incorrect
        }
        
        // Now we check for the correct positions - index of one hand touching the thumb of another hand
        let distance1 = indexHand1.length(to: thumbHand2)/palmLength
        if isLessOrEqual(distance1, Self.TOUCHING_THRESHOLD) {
            return .correct
        }
        let distance2 = indexHand2.length(to: thumbHand1)/palmLength
        if isLessOrEqual(distance2, Self.TOUCHING_THRESHOLD) {
            return .correct
        }
        
        // If the fingers aren't touching correctly, it must be incorrect
        return .incorrect
    }
    
}
