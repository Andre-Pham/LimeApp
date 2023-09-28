//
//  QuizLetter.swift
//  Lime
//
//  Created by Andre Pham on 23/9/2023.
//

import Foundation

protocol QuizLetter {
    
    var letter: Character { get }
    
    func acceptAnswer(answer: HandDetectionOutcome) -> QuizAnswerStatus
    
}
extension QuizLetter {
    
    public static var TOUCHING_THRESHOLD: Double {
        return 0.35
    }
    public static var CLOSE_THRESHOLD: Double {
        return 0.5
    }
    
    func acceptAnswers(answers: [HandDetectionOutcome], passThreshold: Double) -> QuizAnswerOutcome {
        var correctCount = 0
        for answer in answers {
            let result = self.acceptAnswer(answer: answer)
            if result == .correct {
                correctCount += 1
            }
        }
        let percentageCorrect = Double(correctCount)/Double(answers.count)
        return QuizAnswerOutcome(
            status: isGreaterOrEqual(percentageCorrect, passThreshold) ? .correct : .incorrect,
            grade: percentageCorrect
        )
    }
    
}
