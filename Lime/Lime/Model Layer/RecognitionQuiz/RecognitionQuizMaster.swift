//
//  RecognitionQuizMaster.swift
//  Lime
//
//  Created by Andre Pham on 23/9/2023.
//

import Foundation

class RecognitionQuizMaster {
    
    private var letters = [QuizLetter]()
    private var letterIndex: Int = 0
    private var readyForAnswer = false
    private var loadedLetter: QuizLetter {
        return self.letters[self.letterIndex]
    }
    public var displayLetter: Character {
        return self.loadedLetter.letter
    }
    
    init() { }
    
    func setLetters(to letters: [QuizLetter]) {
        self.letters = letters
    }
    
    func acceptAnswers(answers: [HandDetectionOutcome], passThreshold: Double) -> QuizAnswerOutcome {
        return self.loadedLetter.acceptAnswers(answers: answers, passThreshold: passThreshold)
    }
    
    func moveToNextPrompt() {
        self.letterIndex = (self.letterIndex + 1)%self.letters.count
    }
    
}
