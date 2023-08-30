//
//  LetterDisplayView.swift
//  Lime
//
//  Created by Andre Pham on 5/8/2023.
//

import Foundation
import UIKit

class LetterDisplayView: LimeUIView {
    
    typealias LettersToRemove = [(char: Character, index: Int)]
    typealias LettersToInsert = [(char: Character, index: Int)]
    
    private static let FOCUS_BOX_WIDTH = 50.0
    private static let FOCUS_BOX_HEIGHT = 64.0
    private static let FOCUS_BOX_CORNER_RADIUS = 12.0
    private static let LETTER_SIZE = 32.0
    private static let LETTER_WIDTH = 32.0
    private static let LETTER_OPACITY = 0.4
    private static let FOCUS_LETTER_SIZE = 50.0
    private static let FOCUS_LETTER_WIDTH = 50.0
    private static let FOCUS_LARGE_LETTER_SIZE = 44.0
    
    private var activePrompt = ""
    private var focusedLetterIndex: Int? = nil
    private var focusedLetter: LimeText? {
        guard let index = self.focusedLetterIndex else {
            return nil
        }
        return self.letters[index]
    }
    
    private let container = LimeView()
    private let stack = LimeHStack()
    private var letters = [LimeText]()
    private var letterWidthConstraints = [NSLayoutConstraint]()
    public var view: UIView {
        return self.container.view
    }
    
    override init() {
        self.container
            .setWidthConstraint(to: Self.FOCUS_BOX_WIDTH)
            .setHeightConstraint(to: Self.FOCUS_BOX_HEIGHT)
            .setCornerRadius(to: Self.FOCUS_BOX_CORNER_RADIUS)
            .addSubview(self.stack)
        
        self.stack
            .constrainVertical()
            .constrainCenterHorizontal()
    }
    
    /// Set a new prompt. Resets focused letter.
    /// Doesn't reapply a new focus  (`focusLetter` must be recalled).
    /// - Parameters:
    ///   - prompt: The new prompt
    func setPrompt(to prompt: String) {
        self.resetFocusedLetter()
        
        if prompt.isEmpty {
            self.container.setBackgroundColor(to: .clear)
        } else {
            self.container.setBackgroundColor(to: LimeColors.toolbarFill)
        }
        
        let prompt = prompt.uppercased()
        let (lettersToRemove, lettersToInsert) = self.findLetterSwaps(old: self.activePrompt, new: prompt)
        
        for letter in lettersToRemove.reversed() {
            self.letters[letter.index].removeFromSuperView()
            self.letters.remove(at: letter.index)
            self.letterWidthConstraints.remove(at: letter.index)
        }
        
        for letter in lettersToInsert {
            let letterView = LimeText()
                .setFont(to: LimeFont(font: LimeFonts.Poppins.Bold.rawValue, size: Self.LETTER_SIZE))
                .setText(to: String(letter.char))
                .setTextAlignment(to: .center)
                .setTextOpacity(to: Self.LETTER_OPACITY)
            let widthConstraint = letterView.view.widthAnchor.constraint(equalToConstant: Self.LETTER_WIDTH)
            widthConstraint.isActive = true
            self.letterWidthConstraints.insert(widthConstraint, at: letter.index)
            self.stack.addViewAnimated(letterView, position: letter.index)
            self.letters.insert(letterView, at: letter.index)
        }
        
        self.activePrompt = prompt
    }
    
    /// Place a letter into focus.
    /// - Parameters:
    ///   - index: The position of the letter to focus
    ///   - duration: The animation duration for switching between the letters
    func focusLetter(_ index: Int, duration: Double) {
        assert(index < self.letters.count, "Invalid index provided")
        guard index != self.focusedLetterIndex else { return }
        
        self.resetFocusedLetter()
        
        let letter = self.letters[index]
        letter
            .setSize(to: letter.text == "W" || letter.text == "M" ? Self.FOCUS_LARGE_LETTER_SIZE : Self.FOCUS_LETTER_SIZE)
            .setTextOpacity(to: 1.0)
        self.letterWidthConstraints[index].constant = Self.FOCUS_LETTER_WIDTH
        
        // Calculate total width of all letters to the left
        var leftWidth = 0.0
        for viewIndex in 0..<index {
            leftWidth += viewIndex == self.focusedLetterIndex ? Self.FOCUS_LETTER_WIDTH : Self.LETTER_WIDTH
        }
        // Calculate total width of all letters to the right
        var rightWidth = 0.0
        for viewIndex in (index + 1)..<self.letters.count {
            rightWidth += viewIndex == self.focusedLetterIndex ? Self.FOCUS_LETTER_WIDTH : Self.LETTER_WIDTH
        }
        // Get half the width of the letter in question
        let halfWay = Self.FOCUS_LETTER_WIDTH/2.0
        
        let letterCenter = leftWidth + halfWay
        
        // Get length from centre of stack to letter
        let offset = ((Double(self.letters.count) - 1.0)*Self.LETTER_WIDTH + Self.FOCUS_LETTER_WIDTH)/2.0 - letterCenter
        
        UIView.animate(withDuration: duration) {
            self.stack.setTransformation(to: CGAffineTransform(translationX: offset, y: 0))
        }
        
        self.focusedLetterIndex = index
    }
    
    /// Return the focused letter back to its original styling, then set the focused letter to nil.
    private func resetFocusedLetter() {
        self.focusedLetter?
            .setSize(to: Self.LETTER_SIZE)
            .setTextOpacity(to: Self.LETTER_OPACITY)
        if let focusedLetterIndex {
            self.letterWidthConstraints[focusedLetterIndex].constant = Self.LETTER_WIDTH
        }
        self.focusedLetterIndex = nil
    }
    
    /// Find the letters to swap out (insert and remove) to form a new string from an old string.
    /// Contains the minimum insert + remove actions to accomplish getting from the old to the new string.
    /// https://chat.openai.com/share/5363eea3-cc41-4951-a2fc-112b2d62effc
    /// - Parameters:
    ///   - old: The old string
    ///   - new: The new string to be formed from the letters to remove an insert
    /// - Returns: The minimum letters to insert and remove to form the new string from the old
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
