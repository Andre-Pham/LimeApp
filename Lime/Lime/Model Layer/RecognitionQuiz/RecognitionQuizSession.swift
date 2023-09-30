//
//  RecognitionQuizSession.swift
//  Lime
//
//  Created by Andre Pham on 25/9/2023.
//

import Foundation

class RecognitionQuizSession {
    
    /// Singleton instance
    public static let inst = RecognitionQuizSession()
    
    private static let BATCH_SIZE = 20
    private static let PASS_THRESHOLD = 0.5
    
    private let quizMaster = RecognitionQuizMaster()
    private var handDetectionOutcomes = [HandDetectionOutcome]()
    private(set) var isAcceptingInput = false
    public weak var recognitionQuizDelegate: RecognitionQuizDelegate?
    public var displayLetter: Character {
        return self.quizMaster.displayLetter
    }
    
    private init() { }
    
    func setLetterPrompt(to letters: String) {
        var quizLetters = [QuizLetter]()
        for letter in letters {
            switch letter {
            case "A":
                quizLetters.append(QuizLetterA())
            case "B":
                quizLetters.append(QuizLetterB())
            case "C":
                quizLetters.append(QuizLetterC())
            default:
                continue
            }
        }
        self.quizMaster.setLetters(to: quizLetters)
    }
    
    func receiveHandDetectionOutcome(_ handDetectionOutcome: HandDetectionOutcome) {
        guard self.isAcceptingInput else {
            return
        }
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
    
    func markReadyForInput() {
        self.isAcceptingInput = true
    }
    
    func disableInput() {
        self.isAcceptingInput = false
        self.handDetectionOutcomes.removeAll()
    }
    
}
