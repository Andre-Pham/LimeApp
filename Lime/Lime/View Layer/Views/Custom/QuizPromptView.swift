//
//  QuizPromptView.swift
//  Lime
//
//  Created by Andre Pham on 24/9/2023.
//

import Foundation
import UIKit

class QuizPromptView: LimeUIView {
    
    private let container = LimeView()
    private let stack = LimeVStack()
    private let promptText = LimeText()
    private let letterText = LimeText()
    private let correctIcon = LimeImage()
    
    public var view: UIView {
        return self.container.view
    }
    
    override init() {
        super.init()
        
        self.container
            .setBackgroundColor(to: LimeColors.toolbarFill)
            .setCornerRadius(to: LimeDimensions.foregroundCornerRadius)
            .addSubview(self.stack)
        
        self.stack
            .constrainTop(padding: LimeDimensions.chipPaddingVertical)
            .constrainBottom(padding: LimeDimensions.chipPaddingVertical/2)
            .constrainHorizontal(padding: LimeDimensions.chipPaddingHorizontal)
            .setSpacing(to: 6)
            .addView(self.promptText)
            .addView(self.letterText)
        
        self.promptText
            .setFont(to: LimeFont(font: LimeFonts.Poppins.SemiBold.rawValue, size: 12))
            .setTextAlignment(to: .center)
        
        self.correctIcon
            .setImage(UIImage(
                systemName: "checkmark.circle",
                withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)
            )!)
            .setColor(to: LimeColors.textWhite)
        
        self.letterText
            .setFont(to: LimeFont(font: LimeFonts.Poppins.Bold.rawValue, size: 64))
            .setTextAlignment(to: .center)
            .setHeightConstraint(to: self.letterText.font.pointSize)
    }
    
    @discardableResult
    func setPromptText(to prompt: String) -> Self {
        self.promptText.setText(to: prompt.uppercased())
        return self
    }
    
    @discardableResult
    func setLetter(to letter: Character) -> Self {
        self.letterText.setText(to: String(letter))
        return self
    }
    
    func markCorrect(onCompletion: @escaping () -> Void) {
        UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            self.container.setBackgroundColor(to: LimeColors.success)
            self.promptText.setTextColor(to: LimeColors.success)
            self.letterText.setTextColor(to: LimeColors.success)
            self.container.addSubview(self.correctIcon)
            self.correctIcon
                .constrainAllSides(padding: 20)
                .animateEntrance()
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onCompletion()
            }
        })
    }
    
    func reset() {
        self.container.setBackgroundColor(to: LimeColors.toolbarFill)
        self.promptText.setTextColor(to: LimeColors.textDark)
        self.letterText.setTextColor(to: LimeColors.textDark)
        self.correctIcon.removeFromSuperView()
    }
    
}
