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
        // Don't bother checking for little finger - it's more of a liability then a reliability check
        let hand1FingerTips = [hand1.thumb4, hand1.index4, hand1.middle4, hand1.ring4]
        let hand2FingerTips = [hand2.thumb4, hand2.index4, hand2.middle4, hand2.ring4]
        let hand1Positions = hand1FingerTips.compactMap({ $0.position })
        let hand2Positions = hand2FingerTips.compactMap({ $0.position })
        guard hand1Positions.count == hand1FingerTips.count && hand2Positions.count == hand2FingerTips.count else {
            return .incorrect
        }
        for position1 in hand1Positions {
            for position2 in hand2Positions {
                if isGreater(
                    position1.length(to: position2)/((hand1.getPalmLength() + hand2.getPalmLength())/2.0),
                    Self.CLOSE_THRESHOLD
                ) {
                    return .incorrect
                }
            }
        }
        return .correct
    }
    
}
