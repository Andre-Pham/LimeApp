//
//  CameraWarningView.swift
//  Lime
//
//  Created by Andre Pham on 25/9/2023.
//

import Foundation
import UIKit

class CameraWarningView: LimeUIView {
    
    private let container = LimeView()
    private let stack = LimeHStack()
    private let warningIcon = LimeImage()
    private let warningText = LimeText()
    public var view: UIView {
        return self.container.view
    }
    
    override init() {
        super.init()
        
        self.container
            .setBackgroundColor(to: LimeColors.warning)
            .setCornerRadius(to: LimeDimensions.foregroundCornerRadius)
            .setWidthConstraint(to: LimeDimensions.popupWidth)
            .addSubview(self.stack)
        
        self.stack
            .constrainVertical(padding: 12)
            .constrainCenterHorizontal()
            .setMaxWidthConstraint(to: LimeDimensions.popupWidth - 12*2)
            .setSpacing(to: 12)
            .addView(self.warningIcon)
            .addView(self.warningText)
        
        self.warningIcon
            .constrainVertical()
            .setWidthConstraint(to: 32)
            .setContentMode(to: .scaleAspectFit)
            .setImage(UIImage(systemName: "exclamationmark.triangle.fill")!)
            .setColor(to: .white)
        
        self.warningText
            .setTextAlignment(to: .center)
            .setFont(to: LimeFont(font: LimeFonts.Poppins.SemiBold.rawValue, size: 24))
            .setTextColor(to: LimeColors.textWhite)
    }
    
    @discardableResult
    func setWarning(to warning: String) -> Self {
        self.warningText.setText(to: warning)
        return self
    }
    
}
