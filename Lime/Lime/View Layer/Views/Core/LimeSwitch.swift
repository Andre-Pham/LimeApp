//
//  LimeSwitch.swift
//  Lime
//
//  Created by Andre Pham on 30/6/2023.
//

import Foundation
import UIKit

class LimeSwitch: LimeUIView, LimeViewPublisher {
    
    var subscribers = [WeakLimeViewObserver]()
    
    private let switchView = UISwitch()
    private var onFlick: ((_ isOn: Bool) -> Void)? = nil
    
    public var isOn: Bool {
        return self.switchView.isOn
    }
    public var view: UIView {
        return self.switchView
    }
    
    override init() {
        super.init()
        self.switchView.addTarget(self, action: #selector(self.switchValueChanged(_:)), for: .valueChanged)
    }
    
    @discardableResult
    func setState(isOn: Bool, animated: Bool = true) -> Self {
        let before = self.isOn
        self.switchView.setOn(isOn, animated: animated)
        // If the value is the same, we still trigger the callback
        if isOn == before {
            self.switchValueChanged(self.switchView)
        }
        return self
    }
    
    @discardableResult
    func setOnFlick(_ callback: ((_ isOn: Bool) -> Void)?) -> Self {
        self.onFlick = callback
        return self
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        self.onFlick?(self.isOn)
        self.publish(self)
   }
    
}
