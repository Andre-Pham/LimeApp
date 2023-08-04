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
        view.setHidden(to: true)
        if let position {
            let validatedPosition = min(position, self.stack.arrangedSubviews.count)
            self.stack.insertArrangedSubview(view.view, at: validatedPosition)
        } else {
            self.stack.addArrangedSubview(view.view)
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            view.setHidden(to: false)
        })
        return self
    }
    
    @discardableResult
    func removeViewAnimated(_ view: LimeUIView) -> Self {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            view.setHidden(to: true)
        }) { _ in
            view.removeFromSuperView()
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
