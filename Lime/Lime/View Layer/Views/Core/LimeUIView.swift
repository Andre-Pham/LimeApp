//
//  LimeView.swift
//  Lime
//
//  Created by Andre Pham on 14/6/2023.
//

import Foundation
import UIKit

typealias LimeUIView = LimeUIViewAbstract & LimeUIViewProtocol

// MARK: - Abstract

class LimeUIViewAbstract {
    
    public let id = UUID()
    
    init() { }
    
}

// MARK: - Protocol

protocol LimeUIViewProtocol {
    
    var view: UIView { get }
    
}
extension LimeUIViewProtocol {
    
    // MARK: - Properties
    
    public var isHidden: Bool {
        return self.view.isHidden
    }
    
    public var frame: CGRect {
        return self.view.frame
    }
    
    public var bottomAnchor: NSLayoutYAxisAnchor {
        return self.view.bottomAnchor
    }
    
    public var topAnchor: NSLayoutYAxisAnchor {
        return self.view.topAnchor
    }
    
    public var leftAnchor: NSLayoutXAxisAnchor {
        return self.view.leftAnchor
    }
    
    public var rightAnchor: NSLayoutXAxisAnchor {
        return self.view.rightAnchor
    }
    
    public var superView: LimeView? {
        if let superView = self.view.superview {
            return LimeView(superView)
        }
        return nil
    }
    
    // MARK: - Views
    
    @discardableResult
    func addSubview(_ view: LimeUIView) -> Self {
        self.view.addSubview(view.view)
        return self
    }
    
    @discardableResult
    func clearSubviewsAndLayers() -> Self {
        self.view.subviews.forEach({ $0.removeFromSuperview() })
        self.view.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        return self
    }
    
    @discardableResult
    func removeFromSuperView() -> Self {
        self.view.removeFromSuperview()
        return self
    }
    
    // MARK: - Frame
    
    @discardableResult
    func setFrame(to rect: CGRect) -> Self {
        self.view.frame = rect
        return self
    }
    
    // MARK: - Constraints
    
    @discardableResult
    func matchWidthConstraint(to other: LimeUIView? = nil, respectSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.widthAnchor : target.widthAnchor
        self.view.widthAnchor.constraint(equalTo: anchor).isActive = true
        return self
    }
    
    @discardableResult
    func matchHeightConstraint(to other: LimeUIView? = nil, respectSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.heightAnchor : target.heightAnchor
        self.view.widthAnchor.constraint(equalTo: anchor).isActive = true
        return self
    }
    
    @discardableResult
    func setHeightConstraint(to height: Double) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        self.view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return self
    }
    
    @discardableResult
    func setWidthConstraint(to width: Double) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        self.view.widthAnchor.constraint(equalToConstant: width).isActive = true
        return self
    }
    
    @discardableResult
    func constrainLeft(to other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.leadingAnchor : target.leadingAnchor
        self.view.leadingAnchor.constraint(equalTo: anchor, constant: padding).isActive = true
        return self
    }
    
    @discardableResult
    func constrainRight(to other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.trailingAnchor : target.trailingAnchor
        self.view.trailingAnchor.constraint(equalTo: anchor, constant: -padding).isActive = true
        return self
    }
    
    @discardableResult
    func constrainTop(to other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.topAnchor : target.topAnchor
        self.view.topAnchor.constraint(equalTo: anchor, constant: padding).isActive = true
        return self
    }
    
    @discardableResult
    func constrainBottom(to other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.bottomAnchor : target.bottomAnchor
        self.view.bottomAnchor.constraint(equalTo: anchor, constant: -padding).isActive = true
        return self
    }
    
    @discardableResult
    func constrainHorizontal(to other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        self.constrainLeft(to: other, padding: padding)
        self.constrainRight(to: other, padding: padding)
        return self
    }
    
    @discardableResult
    func constrainVertical(to other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        self.constrainTop(to: other, padding: padding, respectSafeArea: respectSafeArea)
        self.constrainBottom(to: other, padding: padding, respectSafeArea: respectSafeArea)
        return self
    }
    
    @discardableResult
    func constrainAllSides(to other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        self.constrainHorizontal(to: other, padding: padding, respectSafeArea: respectSafeArea)
        self.constrainVertical(to: other, padding: padding, respectSafeArea: respectSafeArea)
        return self
    }
    
    @discardableResult
    func constrainToUnderneath(of other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.bottomAnchor : target.bottomAnchor
        self.view.topAnchor.constraint(equalTo: anchor, constant: padding).isActive = true
        return self
    }
    
    @discardableResult
    func constrainToOnTop(of other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.topAnchor : target.topAnchor
        self.view.bottomAnchor.constraint(equalTo: anchor, constant: -padding).isActive = true
        return self
    }
    
    @discardableResult
    func constrainToRightSide(of other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.rightAnchor : target.rightAnchor
        self.view.leftAnchor.constraint(equalTo: anchor, constant: padding).isActive = true
        return self
    }
    
    @discardableResult
    func constrainToLeftSide(of other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.leftAnchor : target.leftAnchor
        self.view.rightAnchor.constraint(equalTo: anchor, constant: -padding).isActive = true
        return self
    }
    
    @discardableResult
    func constrainCenterVertical(to other: LimeUIView? = nil, respectSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.centerYAnchor : target.centerYAnchor
        self.view.centerYAnchor.constraint(equalTo: anchor).isActive = true
        return self
    }
    
    @discardableResult
    func constrainCenterHorizontal(to other: LimeUIView? = nil, respectSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.centerXAnchor : target.centerXAnchor
        self.view.centerXAnchor.constraint(equalTo: anchor).isActive = true
        return self
    }
    
    @discardableResult
    func setPadding(top: CGFloat? = nil, bottom: CGFloat? = nil, left: CGFloat? = nil, right: CGFloat? = nil) -> Self {
        self.view.layoutMargins = UIEdgeInsets(
            top: top ?? self.view.layoutMargins.top,
            left: left ?? self.view.layoutMargins.left,
            bottom: bottom ?? self.view.layoutMargins.bottom,
            right: right ?? self.view.layoutMargins.right
        )
        return self
    }
    
    @discardableResult
    func setPaddingVertical(to padding: CGFloat) -> Self {
        return self.setPadding(top: padding, bottom: padding)
    }
    
    @discardableResult
    func setPaddingHorizontal(to padding: CGFloat) -> Self {
        return self.setPadding(left: padding, right: padding)
    }
    
    @discardableResult
    func setPaddingAllSides(to padding: CGFloat) -> Self {
        self.setPaddingVertical(to: padding)
        self.setPaddingHorizontal(to: padding)
        return self
    }
    
    @discardableResult
    func removeWidthConstraint() -> Self {
        for constraint in self.view.constraints {
            if constraint.firstAttribute == .width && constraint.firstItem as? UIView == self.view {
                // Remove any width constraints
                self.view.removeConstraint(constraint)
            }
        }
        return self
    }
    
    @discardableResult
    func removeHeightConstraint() -> Self {
        for constraint in self.view.constraints {
            if constraint.firstAttribute == .height && constraint.firstItem as? UIView == self.view {
                // Remove any height constraints
                self.view.removeConstraint(constraint)
            }
        }
        return self
    }
    
    // MARK: - Background
    
    @discardableResult
    func setBackgroundColor(to color: UIColor) -> Self {
        self.view.backgroundColor = color
        return self
    }
    
    @discardableResult
    func setCornerRadius(to radius: Double) -> Self {
        self.view.layer.cornerRadius = radius
        return self
    }
    
    @discardableResult
    func addBorder(width: CGFloat = 1.0, color: UIColor = UIColor.red) -> Self {
        self.view.layer.borderWidth = width
        self.view.layer.borderColor = color.cgColor
        return self
    }
    
    @discardableResult
    func addSidedBorder(
        width: CGFloat = 1.0,
        color: UIColor = UIColor.red,
        padding: Double = 0.0,
        lengthPadding: Double = 0.0,
        left: Bool = false,
        right: Bool = false,
        top: Bool = false,
        bottom: Bool = false
    ) -> Self {
        if left {
            let borderView = LimeView()
            self.addSubview(borderView)
            borderView
                .constrainVertical(padding: lengthPadding)
                .constrainToRightSide(padding: padding)
                .setWidthConstraint(to: width)
                .setBackgroundColor(to: color)
        }
        if right {
            let borderView = LimeView()
            self.addSubview(borderView)
            borderView
                .constrainVertical(padding: lengthPadding)
                .constrainToLeftSide(padding: padding)
                .setWidthConstraint(to: width)
                .setBackgroundColor(to: color)
        }
        if top {
            let borderView = LimeView()
            self.addSubview(borderView)
            borderView
                .constrainHorizontal(padding: lengthPadding)
                .constrainToOnTop(padding: padding)
                .setHeightConstraint(to: width)
                .setBackgroundColor(to: color)
        }
        if bottom {
            let borderView = LimeView()
            self.addSubview(borderView)
            borderView
                .constrainHorizontal(padding: lengthPadding)
                .constrainToUnderneath(padding: padding)
                .setHeightConstraint(to: width)
                .setBackgroundColor(to: color)
        }
        return self
    }
    
    // MARK: - Visibility
    
    @discardableResult
    func setHidden(to isHidden: Bool) -> Self {
        self.view.isHidden = isHidden
        return self
    }
    
    @discardableResult
    func setOpacity(to opacity: Double) -> Self {
        self.view.alpha = opacity
        return self
    }
    
    // MARK: - Animations
    
    @discardableResult
    func animateOpacityInteraction() -> Self {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            self.view.alpha = 0.25
        }) { _ in
            UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState], animations: {
                self.view.alpha = 1.0
            }, completion: nil)
        }
        return self
    }
    
    @discardableResult
    func animatePressedOpacity() -> Self {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            self.view.alpha = 0.25
        }, completion: nil)
        return self
    }
    
    @discardableResult
    func animateReleaseOpacity() -> Self {
        UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState], animations: {
            self.view.alpha = 1.0
        }, completion: nil)
        return self
    }
    
    @discardableResult
    func animateEntrance() -> Self {
        self.setOpacity(to: 0.0)
        self.view.transform = CGAffineTransform(translationX: 0, y: -10)
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2, options: [.curveEaseOut], animations: {
            self.setOpacity(to: 1.0)
            self.view.transform = CGAffineTransform(translationX: 0, y: 0)
        })
        return self
    }
    
    @discardableResult
    func animateExit(onCompletion: @escaping () -> Void) -> Self {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2, options: [.curveEaseOut], animations: {
            self.setOpacity(to: 0.0)
            self.view.transform = CGAffineTransform(translationX: 0, y: -10)
        }) { _ in
            onCompletion()
        }
        return self
    }
    
    // MARK: - Transformations
    
    @discardableResult
    func setTransformation(to transformation: CGAffineTransform) -> Self {
        self.view.transform = transformation
        return self
    }
    
}
