//
//  RecognitionQuizDelegate.swift
//  Lime
//
//  Created by Andre Pham on 25/9/2023.
//

import Foundation

protocol RecognitionQuizDelegate: AnyObject {
    
    func onCorrectSignPerformed(letter: Character, next: Character)
    
}
