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
        
        self.letterText
            .setFont(to: LimeFont(font: LimeFonts.Poppins.Bold.rawValue, size: 64))
            .setTextAlignment(to: .center)
            .setHeightConstraint(to: self.letterText.font.pointSize)
    }
    
    @discardableResult
    func setPromptText(to prompt: String) -> Self {
        self.promptText.setText(to: prompt.capitalized)
        return self
    }
    
    @discardableResult
    func setLetter(to letter: Character) -> Self {
        self.letterText.setText(to: String(letter))
        return self
    }
    
}
