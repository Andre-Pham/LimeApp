//
//  LimeChipToggle.swift
//  Lime
//
//  Created by Andre Pham on 4/8/2023.
//

import Foundation
import UIKit

class LimeChipToggle: LimeUIView {
    
    private let container = LimeView()
    private let button = LimeControl()
    private let imageView = LimeImage()
    private var disabledColor = LimeColors.secondaryButtonFill
    private var enabledColor = LimeColors.primaryButtonFill
    private var disabledIconColor = LimeColors.secondaryButtonText
    private var enabledIconColor = LimeColors.primaryButtonText
    private(set) var isEnabled = false
    private var onTap: ((_ isEnabled: Bool) -> Void)? = nil
    public var view: UIView {
        return self.container.view
    }
    
    override init() {
        super.init()
        
        self.container
            .setWidthConstraint(to: LimeDimensions.chipWidth)
            .setHeightConstraint(to: LimeDimensions.chipHeight)
            .setBackgroundColor(to: self.disabledColor)
            .setCornerRadius(to: LimeDimensions.foregroundCornerRadius)
            .addSubview(self.button)
            .addSubview(self.imageView)
        
        self.button
            .constrainAllSides()
            .setOnPress({
                self.container.animatePressedOpacity()
            })
            .setOnRelease({
                self.onTapCallback()
                self.container.animateReleaseOpacity()
            })
        
        self.imageView
            .constrainHorizontal(padding: LimeDimensions.chipPaddingHorizontal)
            .constrainVertical(padding: LimeDimensions.chipPaddingVertical)
            .setColor(to: self.disabledIconColor)
    }
    
    private func refresh() {
        self.container.setBackgroundColor(to: self.isEnabled ? self.enabledColor : self.disabledColor)
        self.imageView.setColor(to: self.isEnabled ? self.enabledIconColor : self.disabledIconColor)
    }
    
    @discardableResult
    func setIcon(to icon: String) -> Self {
        if let image = UIImage(named: icon) {
            self.imageView.setImage(image)
        } else if let image = UIImage(systemName: icon) {
            self.imageView.setImage(image)
        }
        return self
    }
    
    @discardableResult
    func setColor(enabled: UIColor, disabled: UIColor) -> Self {
        self.enabledColor = enabled
        self.disabledColor = disabled
        self.refresh()
        return self
    }
    
    @discardableResult
    func setIconColor(enabled: UIColor, disabled: UIColor) -> Self {
        self.enabledIconColor = enabled
        self.disabledIconColor = disabled
        self.refresh()
        return self
    }
    
    @discardableResult
    func setOnTap(_ callback: ((_ isEnabled: Bool) -> Void)?) -> Self {
        self.onTap = callback
        return self
    }
    
    private func onTapCallback() {
        self.isEnabled.toggle()
        self.refresh()
        self.onTap?(self.isEnabled)
    }
    
}
