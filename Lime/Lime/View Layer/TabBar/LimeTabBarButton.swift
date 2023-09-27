//
//  LimeTabBarButton.swift
//  Lime
//
//  Created by Andre Pham on 28/9/2023.
//

import Foundation
import UIKit

class LimeTabBarButton: LimeUIView {
    
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
            .setBackgroundColor(to: LimeColors.secondaryButtonFill)
            .addSubview(self.button)
            .addSubview(self.imageView)
        
        self.button
            .constrainAllSides()
            .setOnRelease({
                self.onTapCallback()
            })
        
        self.imageView
            .constrainCenterVertical()
            .constrainCenterHorizontal()
            .setColor(to: LimeColors.textSecondaryButton)
    }
    
    @discardableResult
    func setIcon(to icon: String) -> Self {
        if let image = UIImage(named: icon) {
            let configuration = UIImage.SymbolConfiguration(pointSize: 28, weight: .light, scale: .small)
            self.imageView.setImage(image.withConfiguration(configuration))
        } else if let image = UIImage(systemName: icon) {
            let configuration = UIImage.SymbolConfiguration(pointSize: 28, weight: .light, scale: .small)
            self.imageView.setImage(image.withConfiguration(configuration))
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
