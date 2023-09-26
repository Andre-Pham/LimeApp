//
//  LimeDialogueBox.swift
//  Lime
//
//  Created by Andre Pham on 25/9/2023.
//

import Foundation
import UIKit

class LimeDialogueBox: LimeUIView {
    
    private let container = LimeView()
    private let stack = LimeVStack()
    private let buttonStack = LimeHStack()
    private let title = LimeText()
    private let body = LimeText()
    private let acceptButton = LimeButton()
    private let cancelButton = LimeButton()
    private var onAccept: (() -> Void)? = nil
    private var onCancel: (() -> Void)? = nil
    public var view: UIView {
        return self.container.view
    }
    
    override init() {
        super.init()
        
        self.container
            .setWidthConstraint(to: LimeDimensions.popupWidth)
            .setBackgroundColor(to: LimeColors.toolbarFill)
            .setCornerRadius(to: LimeDimensions.foregroundCornerRadius)
            .addSubview(self.stack)
        
        self.stack
            .constrainVertical(padding: LimeDimensions.dialogueInnerPadding)
            .constrainHorizontal(padding: LimeDimensions.dialogueInnerPadding)
            .addView(self.title)
            .addGap(size: 16)
            .addView(self.body)
            .addGap(size: 32)
            .addView(self.buttonStack)
        
        self.title
            .setFont(to: LimeFont(font: LimeFonts.PlusJakartaSans.ExtraBold.rawValue, size: 28))
            .setTextColor(to: LimeColors.textDark)
            .setTextAlignment(to: .center)
        
        self.body
            .setFont(to: LimeFont(font: LimeFonts.PlusJakartaSans.SemiBold.rawValue, size: 16))
            .setTextColor(to: LimeColors.textSemiDark)
            .setTextAlignment(to: .center)
        
        self.buttonStack
            .constrainHorizontal()
            .setSpacing(to: 8.0)
            .addView(self.cancelButton)
            .addView(self.acceptButton)
        
        self.cancelButton
            .setColor(to: LimeColors.secondaryButtonFill)
            .setFont(to: LimeFont(font: LimeFonts.Poppins.Bold.rawValue, size: 18), color: LimeColors.textSecondaryButton)
            .setOnTap({
                self.onCancelCallback()
            })
        
        self.acceptButton
            .setColor(to: LimeColors.primaryButtonFill)
            .setFont(to: LimeFont(font: LimeFonts.Poppins.Bold.rawValue, size: 18), color: LimeColors.textPrimaryButton)
            .setOnTap({
                self.onAcceptCallback()
            })
    }
    
    @discardableResult
    func setTitle(to title: String) -> Self {
        self.title.setText(to: title)
        return self
    }
    
    @discardableResult
    func setBody(to body: String) -> Self {
        self.body.setText(to: body)
        return self
    }
    
    @discardableResult
    func setTitleFont(to font: UIFont) -> Self {
        self.title.setFont(to: font)
        return self
    }
    
    @discardableResult
    func setBodyFont(to font: UIFont) -> Self {
        self.body.setFont(to: font)
        return self
    }
    
    @discardableResult
    func removeCancel() -> Self {
        self.cancelButton.removeFromSuperView()
        return self
    }
    
    @discardableResult
    func setAcceptButtonText(to text: String) -> Self {
        self.acceptButton
            .setLabel(to: text)
            // TODO: Remove this when button LimeButton is reworked to not use UIButton
            .setFont(to: LimeFont(font: LimeFonts.Poppins.Bold.rawValue, size: 18), color: LimeColors.textPrimaryButton)
        return self
    }
    
    @discardableResult
    func setCancelButtonText(to text: String) -> Self {
        self.cancelButton
            .setLabel(to: text)
            // TODO: Remove this when button LimeButton is reworked to not use UIButton
            .setFont(to: LimeFont(font: LimeFonts.Poppins.Bold.rawValue, size: 18), color: LimeColors.textSecondaryButton)
        return self
    }
    
    @discardableResult
    func setOnAccept(_ callback: (() -> Void)?) -> Self {
        self.onAccept = callback
        return self
    }
    
    private func onAcceptCallback() {
        self.onAccept?()
    }
    
    @discardableResult
    func setOnCancel(_ callback: (() -> Void)?) -> Self {
        self.onCancel = callback
        return self
    }
    
    private func onCancelCallback() {
        self.onCancel?()
    }
    
}
