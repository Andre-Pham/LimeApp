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
            .setCornerRadius(to: 20)
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

class LimeChipToggle2: UIControl {
    
    var icon: UIImage? = nil {
        didSet { updateAppearance() }
    }
    var selectedIcon: UIImage? = nil {
        didSet { updateAppearance() }
    }
    var text: String? = nil {
        didSet { updateAppearance() }
    }
    var color: UIColor = .lightGray // Replace with your color
    var selectedColor: UIColor = .blue // Replace with your color
    var textColor: UIColor = .darkGray // Replace with your color
    var selectedTextColor: UIColor = .white // Replace with your color
    private var imageView: UIImageView!
    private var label: UILabel!
    
    private var activeColor: UIColor {
        return isSelected ? selectedColor : color
    }
    private var activeTextColor: UIColor {
        return isSelected ? selectedTextColor : textColor
    }
    private var activeIcon: UIImage? {
        return isSelected ? (selectedIcon ?? icon) : icon
    }
    
    override var isSelected: Bool {
        didSet { updateAppearance() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18) // equivalent to SwiftUI's 'title5' font size
        addSubview(label)
        
        addTarget(self, action: #selector(self.tapped), for: .touchUpInside)
        
        layer.cornerRadius = 12 // Update to match your app's design
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tapped() {
        isSelected.toggle()
        sendActions(for: .valueChanged)
    }
    
    private func updateAppearance() {
        backgroundColor = activeColor
        label.text = text
        label.textColor = activeTextColor
        imageView.image = activeIcon
        imageView.tintColor = activeTextColor
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let padding: CGFloat = 20
        let imageSide: CGFloat = bounds.height - padding * 2
        imageView.frame = CGRect(x: padding, y: padding, width: imageSide, height: imageSide)
        label.frame = CGRect(x: padding * 2 + imageSide, y: padding, width: bounds.width - padding * 3 - imageSide, height: imageSide)
    }
    
}
