//
//  LimeVStack.swift
//  Lime
//
//  Created by Andre Pham on 14/6/2023.
//

import Foundation
import UIKit

class LimeVStack: LimeUIView {
    
    private let stack = UIStackView()
    public var view: UIView {
        return self.stack
    }
    public var viewCount: Int {
        return self.stack.arrangedSubviews.count
    }
    private var verticalSpacer: UIView {
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
        spacerView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return spacerView
    }
    
    override init() {
        super.init()
        // Defaults
        self.stack.axis = .vertical
        self.stack.alignment = .center
        self.stack.translatesAutoresizingMaskIntoConstraints = false
        self.stack.isLayoutMarginsRelativeArrangement = false
    }
    
    @discardableResult
    func addView(_ view: LimeUIView) -> Self {
        self.stack.addArrangedSubview(view.view)
        return self
    }
    
    @discardableResult
    func addViewAnimated(_ view: LimeUIView, position: Int? = nil) -> Self {
        view.setOpacity(to: 0.0)
        view.setHidden(to: true)
        if let position {
            let validatedPosition = min(position, self.stack.arrangedSubviews.count)
            self.stack.insertArrangedSubview(view.view, at: validatedPosition)
        } else {
            self.stack.addArrangedSubview(view.view)
        }
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2, options: [.curveEaseOut], animations: {
            view.setOpacity(to: 1.0)
            view.setHidden(to: false)
        })
        return self
    }
    
    @discardableResult
    func removeViewAnimated(_ view: LimeUIView) -> Self {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2, options: [.curveEaseOut], animations: {
            view.setOpacity(to: 0.0)
            view.setHidden(to: true)
        }) { _ in
            view.removeFromSuperView()
            view.setOpacity(to: 1.0)
            view.setHidden(to: false)
        }
        return self
    }
    
    @discardableResult
    func setSpacing(to spacing: CGFloat) -> Self {
        self.stack.spacing = spacing
        return self
    }
    
    @discardableResult
    func addSpacer() -> Self {
        self.stack.addArrangedSubview(self.verticalSpacer)
        return self
    }
    
    @discardableResult
    func addGap(size: Double, position: Int? = nil, animated: Bool = false) -> Self {
        let gapView = LimeView()
            .setHeightConstraint(to: size)
        if animated {
            self.addViewAnimated(gapView, position: position)
        } else {
            if let position {
                self.insertView(gapView, at: position)
            } else {
                self.addView(gapView)
            }
        }
        return self
    }
    
    @discardableResult
    func insertView(_ view: LimeUIView, at index: Int) -> Self {
        self.stack.insertArrangedSubview(view.view, at: index)
        return self
    }
    
    @discardableResult
    func insertSpacer(at index: Int) -> Self {
        self.stack.insertArrangedSubview(self.verticalSpacer, at: index)
        return self
    }
    
    @discardableResult
    func setDistribution(to distribution: UIStackView.Distribution) -> Self {
        self.stack.distribution = distribution
        return self
    }
    
}
