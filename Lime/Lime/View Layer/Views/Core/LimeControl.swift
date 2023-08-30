//
//  LimeControl.swift
//  Lime
//
//  Created by Andre Pham on 4/8/2023.
//

import Foundation
import UIKit

class LimeControl: LimeUIView {
    
    private let control = UIControl()
    private var onPress: (() -> Void)? = nil
    private var onRelease: (() -> Void)? = nil
    public var view: UIView {
        return self.control
    }
    
    override init() {
        super.init()
        
        self.control.addTarget(self, action: #selector(self.onPressCallback), for: .touchDown)
        self.control.addTarget(self, action: #selector(self.onReleaseCallback), for: [.touchUpInside, .touchUpOutside])
        self.control.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @discardableResult
    func setOnPress(_ callback: (() -> Void)?) -> Self {
        self.onPress = callback
        return self
    }
    
    @discardableResult
    func setOnRelease(_ callback: (() -> Void)?) -> Self {
        self.onRelease = callback
        return self
    }
    
    @objc private func onPressCallback() {
        self.onPress?()
    }
    
    @objc private func onReleaseCallback() {
        self.onRelease?()
    }
    
}
