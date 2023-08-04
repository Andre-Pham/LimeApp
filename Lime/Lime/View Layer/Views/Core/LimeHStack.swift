//
//  LimeHStack.swift
//  Lime
//
//  Created by Andre Pham on 30/6/2023.
//

import Foundation
import UIKit

class LimeHStack: LimeUIView {
    
    private let stack = UIStackView()
    public var view: UIView {
        return self.stack
    }
    private var horizontalSpacer: UIView {
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return spacerView
    }
    
    override init() {
        super.init()
        // Defaults
        self.stack.axis = .horizontal
        self.stack.alignment = .center
        self.stack.translatesAutoresizingMaskIntoConstraints = false
        self.stack.isLayoutMarginsRelativeArrangement = true
    }
    
    @discardableResult
    func addView(_ view: LimeUIView) -> Self {
        self.stack.addArrangedSubview(view.view)
        return self
    }
    
    @discardableResult
    func setSpacing(to spacing: CGFloat) -> Self {
        self.stack.spacing = spacing
        return self
    }
    
    @discardableResult
    func addSpacer() -> Self {
        self.stack.addArrangedSubview(self.horizontalSpacer)
        return self
    }
    
    @discardableResult
    func insertView(_ view: LimeUIView, at index: Int) -> Self {
        self.stack.insertArrangedSubview(view.view, at: index)
        return self
    }
    
    @discardableResult
    func insertSpacer(at index: Int) -> Self {
        self.stack.insertArrangedSubview(self.horizontalSpacer, at: index)
        return self
    }
    
    @discardableResult
    func setDistribution(to distribution: UIStackView.Distribution) -> Self {
        self.stack.distribution = distribution
        return self
    }
    
}

