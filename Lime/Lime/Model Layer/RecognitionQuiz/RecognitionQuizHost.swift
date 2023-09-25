//
//  RecognitionQuizHost.swift
//  Lime
//
//  Created by Andre Pham on 25/9/2023.
//

import Foundation

class RecognitionQuizHost {
    
    // TODO: Make this RecognitionQuizSession
    
    private static let BATCH_SIZE = 20
    private static let PASS_THRESHOLD = 0.5
    
    private let quizMaster = RecognitionQuizMaster()
    private var handDetectionOutcomes = [HandDetectionOutcome]()
    public weak var recognitionQuizDelegate: RecognitionQuizDelegate?
    
    func setLetterPrompt(to letters: String) {
        var quizLetters = [QuizLetter]()
        for letter in letters {
            switch letter {
            case "A":
                quizLetters.append(QuizLetterA())
            case "C":
                quizLetters.append(QuizLetterC())
            default:
                continue
            }
        }
        self.quizMaster.setLetters(to: quizLetters)
    }
    
    func receiveHandDetectionOutcome(_ handDetectionOutcome: HandDetectionOutcome) {
        self.handDetectionOutcomes.append(handDetectionOutcome)
        if self.handDetectionOutcomes.count > Self.BATCH_SIZE {
            self.handDetectionOutcomes.removeUntil(capacity: Self.BATCH_SIZE, takeFromEnd: false)
        }
        let answerOutcome = self.quizMaster.acceptAnswers(
            answers: self.handDetectionOutcomes,
            passThreshold: Self.PASS_THRESHOLD
        )
        if answerOutcome.status == .correct {
            self.handDetectionOutcomes.removeAll()
            let correctLetter = self.quizMaster.displayLetter
            self.quizMaster.moveToNextPrompt()
            self.recognitionQuizDelegate?.onCorrectSignPerformed(letter: correctLetter, next: self.quizMaster.displayLetter)
        }
    }
    
}
