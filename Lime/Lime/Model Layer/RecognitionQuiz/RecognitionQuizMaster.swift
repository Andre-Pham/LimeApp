//
//  RecognitionQuizMaster.swift
//  Lime
//
//  Created by Andre Pham on 23/9/2023.
//

import Foundation

class RecognitionQuizMaster {
    
    private static let PASS_THRESHOLD = 0.5
    
    private var letters = [QuizLetter]()
    private var letterIndex: Int = 0
    private var readyForAnswer = false
    private var loadedLetter: QuizLetter {
        return self.letters[self.letterIndex]
    }
    public var displayLetter: Character {
        return self.loadedLetter.letter
    }
    
    init() {
        
    }
    
    func acceptAnswers(answers: [HandDetectionOutcome]) -> QuizAnswerOutcome {
        return self.loadedLetter.acceptAnswers(answers: answers, passThreshold: Self.PASS_THRESHOLD)
    }
    
    func moveToNextPrompt() {
        self.letterIndex = (self.letterIndex + 1)%self.letters.count
    }
    
}
