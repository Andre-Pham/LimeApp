//
//  LetterDisplayView.swift
//  Lime
//
//  Created by Andre Pham on 5/8/2023.
//

import Foundation
import UIKit

class LetterDisplayView: LimeUIView {
    
    // TODO: This entire thing needs cleaning
    
    typealias LettersToRemove = [(char: Character, index: Int)]
    typealias LettersToInsert = [(char: Character, index: Int)]
    
    private let container = LimeView()
    private let stack = LimeHStack()
    private var letters = [LimeText]()
    private var letterWidthConstraints = [NSLayoutConstraint]()
    private let textMode = false
    private var activePrompt = ""
    private var activeLetter: LimeText? = nil
    private var activeLetterIndex: Int? = nil
    public var view: UIView {
        return self.container.view
    }
    
    override init() {
        self.container
            .setBackgroundColor(to: LimeColors.toolbarFill)
            .setWidthConstraint(to: 50)
            .setHeightConstraint(to: 64)
            .setCornerRadius(to: 12)
            .addSubview(self.stack)
        
        self.stack
            .constrainVertical()
            .constrainCenterHorizontal()
//            .addBorder()
        
//        self.prompt
//
//        self.letter.setFont(to: LimeFont(font: LimeFonts.CircularStd.Black.rawValue, size: 32))
    }
    
    func setPrompt(to prompt: String) {
        self.resetActiveLetter()
        
        let prompt = prompt.uppercased()
        let (lettersToRemove, lettersToInsert) = self.findLetterSwaps(old: self.activePrompt, new: prompt)
        
        for letter in lettersToRemove.reversed() {
            self.letters[letter.index].removeFromSuperView()
            self.letters.remove(at: letter.index)
            self.letterWidthConstraints.remove(at: letter.index)
        }
        
        for letter in lettersToInsert {
            let view = LimeText()
                .setFont(to: LimeFont(font: LimeFonts.CircularStd.Black.rawValue, size: 32))
                .setText(to: String(letter.char))
                .setTextAlignment(to: .center)
                .setTextOpacity(to: 0.4)
            let widthConstraint = view.view.widthAnchor.constraint(equalToConstant: 32)
            widthConstraint.isActive = true
            self.letterWidthConstraints.insert(widthConstraint, at: letter.index)
            self.stack
                .addViewAnimated(view, position: letter.index)
            self.letters.insert(view, at: letter.index)
        }
        
        self.activePrompt = prompt
    }
    
    func centerLetter(_ index: Int) {
        assert(index < self.letters.count, "Invalid index provided")
        guard index != self.activeLetterIndex else { return }
        
        self.resetActiveLetter()
        
        let letter = self.letters[index]
        letter
            .setSize(to: 50)
            .setTextOpacity(to: 1.0)
        self.letterWidthConstraints[index].constant = 50
        
        
        
        // Calculate total width of all letters to the left
        var leftWidth = 0.0
        for viewIndex in 0..<index {
            leftWidth += viewIndex == self.activeLetterIndex ? 50 : 32
        }
        // Calculate total width of all letters to the right
        var rightWidth = 0.0
        for viewIndex in (index + 1)..<self.letters.count {
            rightWidth += viewIndex == self.activeLetterIndex ? 50 : 32
        }
        // Get half the width of the letter in question
        let halfWay = 50/2.0
        
        let letterCenter = leftWidth + halfWay
        
        
//        print(leftWidth)
//        print(rightWidth)
//        print(halfWay)
//        print(self.stack.view.frame.width)
        
        
        // Get length from centre of stack to letter
        let offset = ((Double(self.letters.count) - 1.0)*32.0 + 50.0)/2.0 - letterCenter
        
        UIView.animate(withDuration: 0.5) {
            self.stack.setTransformation(to: CGAffineTransform(translationX: offset, y: 0))
        }
        
        self.activeLetter = letter
        self.activeLetterIndex = index
    }
    
    private func resetActiveLetter() {
        self.activeLetter?
            .setSize(to: 32)
            .setTextOpacity(to: 0.4)
        if let activeLetterIndex {
            self.letterWidthConstraints[activeLetterIndex].constant = 32
        }
        self.activeLetter = nil
        self.activeLetterIndex = nil
    }
    
    // https://chat.openai.com/share/5363eea3-cc41-4951-a2fc-112b2d62effc
    private func findLetterSwaps(old: String, new: String) -> (LettersToRemove, LettersToInsert) {
        let oldChars = Array(old)
        let newChars = Array(new)

        var oldIndex = 0
        var newIndex = 0
        var lettersToRemove: [(Character, Int)] = []
        var lettersToAdd: [(Character, Int)] = []

        while oldIndex < oldChars.count && newIndex < newChars.count {
            if oldChars[oldIndex] == newChars[newIndex] {
                oldIndex += 1
                newIndex += 1
            } else {
                if oldChars[oldIndex...].firstIndex(of: newChars[newIndex]) != nil {
                    lettersToRemove.append((oldChars[oldIndex], oldIndex))
                    oldIndex += 1
                } else {
                    lettersToAdd.append((newChars[newIndex], newIndex))
                    newIndex += 1
                }
            }
        }

        while oldIndex < oldChars.count {
            lettersToRemove.append((oldChars[oldIndex], oldIndex))
            oldIndex += 1
        }

        while newIndex < newChars.count {
            lettersToAdd.append((newChars[newIndex], newIndex))
            newIndex += 1
        }
        
        return (lettersToRemove, lettersToAdd)
    }
    
}
