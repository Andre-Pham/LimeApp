//
//  LimeTextInput.swift
//  Lime
//
//  Created by Andre Pham on 4/8/2023.
//

import Foundation
import UIKit

class LimeTextInput: LimeUIView {
    
    private let textInput = PaddedTextField()
    private var onSubmit: (() -> Void)? = nil
    private var onFocus: (() -> Void)? = nil
    private var onUnfocus: (() -> Void)? = nil
    public var view: UIView {
        return self.textInput
    }
    public var text: String {
        return self.textInput.text ?? ""
    }
    
    override init() {
        super.init()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.setFont(to: LimeFont(font: LimeFonts.Poppins.Medium.rawValue, size: 18))
        self.setTextColor(to: LimeColors.textDark)
        self.setBackgroundColor(to: LimeColors.secondaryButtonFill)
        self.setCornerRadius(to: LimeDimensions.foregroundCornerRadius)
        self.setHeightConstraint(to: LimeDimensions.textInputHeight)
        self.textInput.addTarget(self, action: #selector(handleSubmit), for: .editingDidEndOnExit)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidBeginEditing), name: UITextField.textDidBeginEditingNotification, object: self.textInput)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidEndEditing), name: UITextField.textDidEndEditingNotification, object: self.textInput)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleSubmit() {
        self.onSubmit?()
    }
    
    @objc func textFieldDidBeginEditing(notification: NSNotification) {
        self.onFocus?()
    }

    @objc func textFieldDidEndEditing(notification: NSNotification) {
        self.onUnfocus?()
    }
    
    @discardableResult
    func setOnSubmit(_ callback: (() -> Void)?) -> Self {
        self.onSubmit = callback
        return self
    }
    
    @discardableResult
    func setOnFocus(_ callback: (() -> Void)?) -> Self {
        self.onFocus = callback
        return self
    }
    
    @discardableResult
    func setOnUnfocus(_ callback: (() -> Void)?) -> Self {
        self.onUnfocus = callback
        return self
    }
    
    @discardableResult
    func setSubmitLabel(to label: UIReturnKeyType) -> Self {
        self.textInput.returnKeyType = label
        return self
    }
    
    @discardableResult
    func setPlaceholder(to text: String?) -> Self {
        self.textInput.placeholder = text
        return self
    }
    
    @discardableResult
    func setText(to text: String?) -> Self {
        self.textInput.text = text
        return self
    }
    
    @discardableResult
    func setTextColor(to color: UIColor) -> Self {
        self.textInput.textColor = color
        return self
    }
    
    @discardableResult
    func setFont(to font: UIFont?) -> Self {
        self.textInput.font = font
        return self
    }
    
    @discardableResult
    func setSize(to size: CGFloat) -> Self {
        self.textInput.font = self.textInput.font?.withSize(size)
        return self
    }
    
    @discardableResult
    func setTextAlignment(to alignment: NSTextAlignment) -> Self {
        self.textInput.textAlignment = alignment
        return self
    }
    
}

fileprivate class PaddedTextField: UITextField {
    
    private let padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
}
