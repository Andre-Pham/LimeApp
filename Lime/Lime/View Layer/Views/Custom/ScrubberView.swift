//
//  ScrubberView.swift
//  Lime
//
//  Created by Andre Pham on 5/8/2023.
//

import Foundation
import UIKit

class ScrubberView: LimeUIView {
    
    private static let SCRUBBER_DIAMETER = 30.0
    
    private let container = LimeGestureView()
    private let scrubberBackground = LimeView()
    private let scrubberLine = LimeView()
    private let scrubberControl = LimeView()
    public var view: UIView {
        return self.container.view
    }
    
    private var onStartTracking: (() -> Void)? = nil
    private var onEndTracking: (() -> Void)? = nil
    private var onChange: ((_ proportion: Double) -> Void)? = nil
    private(set) var progressProportion: CGFloat = 0.0 {
        didSet {
            self.updateCirclePosition()
        }
    }
    private(set) var isTracking: Bool = false
    
    override init() {
        super.init()
        
        self.container
            .addSubview(self.scrubberBackground)
            .addSubview(self.scrubberLine)
            .addSubview(self.scrubberControl)
            .setOnGesture({ gesture in
                self.onDrag(gesture)
            })
        
        self.scrubberBackground
            .setBackgroundColor(to: LimeColors.component)
            .constrainHorizontal()
            .constrainCenterVertical()
            .setHeightConstraint(to: Self.SCRUBBER_DIAMETER)
            .setCornerRadius(to: Self.SCRUBBER_DIAMETER/2.0)
        
        self.scrubberLine
            .setBackgroundColor(to: .black)
            .setOpacity(to: 0.15)
            .constrainHorizontal(padding: Self.SCRUBBER_DIAMETER/2.0)
            .constrainCenterVertical()
            .setHeightConstraint(to: 5.0)
            .setCornerRadius(to: 2.5)
        
        self.scrubberControl
            .setBackgroundColor(to: LimeColors.accent)
            .setWidthConstraint(to: Self.SCRUBBER_DIAMETER)
            .setHeightConstraint(to: Self.SCRUBBER_DIAMETER)
            .constrainCenterVertical()
            .setCornerRadius(to: Self.SCRUBBER_DIAMETER/2.0)
    }
    
    func setProgress(to proportion: Double) {
        self.progressProportion = min(1.0, max(0.0, proportion))
    }
    
    @discardableResult
    func setOnStartTracking(_ callback: (() -> Void)?) -> Self {
        self.onStartTracking = callback
        return self
    }
    
    @discardableResult
    func setOnEndTracking(_ callback: (() -> Void)?) -> Self {
        self.onEndTracking = callback
        return self
    }
    
    @discardableResult
    func setOnChange(_ callback: ((_ proportion: Double) -> Void)?) -> Self {
        self.onChange = callback
        return self
    }
    
    private func onDrag(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.isTracking = true
            self.onStartTracking?()
        case .changed:
            let containerWidth = self.container.frame.width
            let lineWidth = containerWidth - Self.SCRUBBER_DIAMETER
            let positionInContainer = gesture.location(in: self.container.view).x
            var positionInLine = {
                let clampedPosition = min(containerWidth - Self.SCRUBBER_DIAMETER/2.0, max(Self.SCRUBBER_DIAMETER/2.0, positionInContainer))
                return clampedPosition - Self.SCRUBBER_DIAMETER/2.0
            }()
            let newProgress = positionInLine/lineWidth
            self.progressProportion = min(1.0, max(0.0, newProgress))
            self.onChange?(self.progressProportion)
        case .ended, .cancelled, .failed:
            self.isTracking = false
            self.onEndTracking?()
        default:
            break
        }
    }
    
    private func updateCirclePosition() {
        let timelineWidth = self.container.view.bounds.width - Self.SCRUBBER_DIAMETER
        let newPosition = progressProportion * timelineWidth + Self.SCRUBBER_DIAMETER / 2
        self.scrubberControl.view.center.x = newPosition
    }
    
}
