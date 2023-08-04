//
//  LimeSlider.swift
//  Lime
//
//  Created by Andre Pham on 30/6/2023.
//

import Foundation
import UIKit

class LimeSlider: LimeUIView, LimeViewPublisher {
    
    var subscribers = [WeakLimeViewObserver]()
    
    private let slider = UISlider()
    private var onDrag: ((_ value: Double) -> Void)? = nil
    
    public var value: Float {
        return self.slider.value
    }
    public var view: UIView {
        return self.slider
    }
    private var roundToNearest: Double? = nil
    
    override init() {
        super.init()
        self.slider.addTarget(self, action: #selector(self.sliderValueChanged(_:)), for: .valueChanged)
    }
    
    @discardableResult
    func setValues(minimumValue: Float?, maximumValue: Float?, value: Float?) -> Self {
        if let minimumValue {
            self.slider.minimumValue = minimumValue
        }
        if let maximumValue {
            self.slider.maximumValue = maximumValue
        }
        if let value {
            self.slider.value = value
            self.publish(self)
        }
        return self
    }
    
    @discardableResult
    func setValues(minimumValue: Int?, maximumValue: Int?, value: Int?) -> Self {
        return self.setValues(
            minimumValue: minimumValue == nil ? nil : Float(minimumValue!),
            maximumValue: maximumValue == nil ? nil : Float(maximumValue!),
            value: value == nil ? nil : Float(value!)
        )
    }
    
    @discardableResult
    func setOnDrag(_ callback: ((_ value: Double) -> Void)?) -> Self {
        self.onDrag = callback
        return self
    }
    
    @discardableResult
    func setRoundToNearest(_ nearest: Double?) -> Self {
        self.roundToNearest = nearest
        return self
    }
    
    @discardableResult
    func setWidth(to width: Double) -> Self {
        self.slider.widthAnchor.constraint(equalToConstant: width).isActive = true
        return self
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        var roundedValue = Double(sender.value)
        if let roundToNearest {
            roundedValue = roundedValue.nearest(roundToNearest)
            roundedValue = max(roundedValue, Double(self.slider.minimumValue))
            roundedValue = min(roundedValue, Double(self.slider.maximumValue))
        }
        sender.value = Float(roundedValue)
        self.onDrag?(roundedValue)
        self.publish(self)
   }
    
}
