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
    public var view: UIView {
        return self.textInput
    }
    public var text: String {
        return self.textInput.text ?? ""
    }
    
    override init() {
        super.init()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.setText(to: text)
        self.setFont(to: UIFont.boldSystemFont(ofSize: 13.0))
        self.setBackgroundColor(to: LimeColors.secondaryButtonFill)
        self.setCornerRadius(to: LimeDimensions.foregroundCornerRadius)
        self.setHeightConstraint(to: 48)
    }
    
    @discardableResult
    func setText(to text: String?) -> Self {
        self.textInput.text = text
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
