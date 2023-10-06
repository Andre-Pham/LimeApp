//
//  LimeIconButton.swift
//  Lime
//
//  Created by Andre Pham on 13/7/2023.
//

import Foundation
import UIKit

class LimeIconButton: LimeUIView {
    
    private let button = UIButton(type: .custom)
    private var onTap: (() -> Void)? = nil
    public var view: UIView {
        return self.button
    }
    public var color: UIColor? {
        return self.button.tintColor
    }
    private var newConfig: UIButton.Configuration {
        return UIButton.Configuration.filled()
    }
    
    override init() {
        super.init()
        self.button.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.filled()
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 6,
            leading: 6,
            bottom: 6,
            trailing: 6
        )
        config.background.cornerRadius = 20
        self.button.configuration = config
        self.button.addTarget(self, action: #selector(self.onTapCallback), for: .touchUpInside)
    }
    
    @discardableResult
    func enableSquareAspectRatio() -> Self {
        self.button.widthAnchor.constraint(equalTo: self.button.heightAnchor).isActive = true
        return self
    }
    
    @discardableResult
    func setRadius(to radius: Double) -> Self {
        self.button.heightAnchor.constraint(equalToConstant: radius/2).isActive = true
        var config = self.button.configuration ?? self.newConfig
        config.background.cornerRadius = radius/2
        self.button.configuration = config
        return self
    }
    
    @discardableResult
    func setIcon(to icon: String) -> Self {
        if let image = UIImage(named: icon) {
            self.button.setImage(image, for: .normal)
        } else if let image = UIImage(systemName: icon) {
            self.button.setImage(image, for: .normal)
        }
        return self
    }
    
    @discardableResult
    func setOnTap(_ callback: (() -> Void)?) -> Self {
        self.onTap = callback
        return self
    }
    
    @discardableResult
    func setColor(to color: UIColor) -> Self {
        self.button.tintColor = color
        return self
    }
    
    @discardableResult
    func setIconColor(to color: UIColor) -> Self {
        self.button.setImage(self.button.currentImage?.withTintColor(color, renderingMode: .alwaysOriginal), for: .normal)
        return self
    }
    
    @discardableResult
    func setIconSize(to size: UIButton.Configuration.Size) -> Self {
        var config = self.button.configuration ?? self.newConfig
        config.buttonSize = .mini
        self.button.configuration = config
        return self
    }
    
    @discardableResult
    func setAccessibilityLabel(to label: String) -> Self {
        self.button.accessibilityLabel = label
        return self
    }
    
    @objc private func onTapCallback() {
        self.onTap?()
    }
    
}
