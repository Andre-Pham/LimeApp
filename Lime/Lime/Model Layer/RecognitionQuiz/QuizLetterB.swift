//
//  QuizLetterB.swift
//  Lime
//
//  Created by Andre Pham on 27/9/2023.
//

import Foundation

class QuizLetterB: QuizLetter {
    
    public let letter: Character = "B"
    
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
        // Only requires thumb and index
        guard let hand1IndexPosition = hand1.index4.getDenormalizedPosition(for: answer.frameSize),
           let hand2IndexPosition = hand2.index4.getDenormalizedPosition(for: answer.frameSize),
           let hand1ThumbPosition = hand1.thumb4.getDenormalizedPosition(for: answer.frameSize),
           let hand2ThumbPosition = hand2.thumb4.getDenormalizedPosition(for: answer.frameSize) else {
            return .incorrect
        }
        let indexesTouching = isLessOrEqual(
            hand1IndexPosition.length(to: hand2IndexPosition)/palmLength,
            Self.TOUCHING_THRESHOLD
        )
        // If camera is facing a downward angle, the thumbs can appear not close to each other
        // Hence we just check if they're close to their respective index finger
        let thumb1Close = isLessOrEqual(
            hand1IndexPosition.length(to: hand1ThumbPosition)/palmLength,
            Self.TOUCHING_THRESHOLD
        )
        let thumb2Close = isLessOrEqual(
            hand2IndexPosition.length(to: hand2ThumbPosition)/palmLength,
            Self.TOUCHING_THRESHOLD
        )
        return (indexesTouching && thumb1Close && thumb2Close) ? .correct : .incorrect
    }
    
}
