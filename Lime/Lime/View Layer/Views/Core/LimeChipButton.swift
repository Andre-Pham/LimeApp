//
//  LimeChipButton.swift
//  Lime
//
//  Created by Andre Pham on 4/8/2023.
//

import Foundation
import UIKit

class LimeChipButton: LimeUIView {
    
    private let container = LimeView()
    private let button = LimeControl()
    private let imageView = LimeImage()
    private var onTap: (() -> Void)? = nil
    public var view: UIView {
        return self.container.view
    }
    
    override init() {
        super.init()
        
        self.container
            .setWidthConstraint(to: 60)
            .setHeightConstraint(to: 48)
            .setBackgroundColor(to: LimeColors.secondaryButtonFill)
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
            .constrainHorizontal(padding: 17)
            .constrainVertical(padding: 14)
            .setColor(to: LimeColors.secondaryButtonText)
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
    func setColor(to color: UIColor) -> Self {
        self.container.setBackgroundColor(to: color)
        return self
    }
    
    @discardableResult
    func setIconColor(to color: UIColor) -> Self {
        self.imageView.setColor(to: color)
        return self
    }
    
    @discardableResult
    func setOnTap(_ callback: (() -> Void)?) -> Self {
        self.onTap = callback
        return self
    }
    
    private func onTapCallback() {
        self.onTap?()
    }
    
}
