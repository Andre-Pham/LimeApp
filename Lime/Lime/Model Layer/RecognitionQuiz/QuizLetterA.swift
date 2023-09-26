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
        // TODO: Also make sure that no other fingers are touching so the user can't just smush all their fingers together
        guard answer.handDetections.count == 2 else {
            return .incorrect
        }
        let hand1 = answer.handDetections[0]
        let hand2 = answer.handDetections[1]
        if let index = hand1.index4.position,
           let thumb = hand2.thumb4.position {
            let distance = index.length(to: thumb)/((hand1.getPalmLength() + hand2.getPalmLength())/2.0)
            if isLessOrEqual(distance, Self.TOUCHING_THRESHOLD) {
                return .correct
            }
        }
        if let index = hand2.index4.position,
           let thumb = hand1.thumb4.position {
            let distance = index.length(to: thumb)/((hand1.getPalmLength() + hand2.getPalmLength())/2.0)
            if isLessOrEqual(distance, Self.TOUCHING_THRESHOLD) {
                return .correct
            }
        }
        return .incorrect
    }
    
}
