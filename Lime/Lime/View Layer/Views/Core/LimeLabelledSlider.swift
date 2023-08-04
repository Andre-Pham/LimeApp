//
//  LimeLabelledSlider.swift
//  Lime
//
//  Created by Andre Pham on 30/6/2023.
//

import Foundation
import UIKit

class LimeLabelledSlider: LimeUIView, LimeViewObserver {
    
    public let stack = LimeHStack()
    public let slider = LimeSlider()
    public let labelText = LimeText()
    public let valueText = LimeText()
    public var view: UIView {
        return self.stack.view
    }
    
    override init() {
        super.init()
        self.stack
            .addView(self.labelText)
            .addView(self.slider)
            .addView(self.valueText)
        self.viewStateDidChange(self.slider)
        self.slider.subscribe(self)
    }
    
    func viewStateDidChange(_ view: LimeUIView) {
        if view.id == self.slider.id { // In case we add other views
            self.valueText.setText(to: "\(Int(self.slider.value))")
        }
    }
    
}
