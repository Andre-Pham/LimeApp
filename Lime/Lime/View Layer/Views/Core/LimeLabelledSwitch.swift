//
//  LimeLabelledSwitch.swift
//  Lime
//
//  Created by Andre Pham on 1/7/2023.
//

import Foundation
import UIKit

class LimeLabelledSwitch: LimeUIView {
    
    public let stack = LimeHStack()
    public let switchView = LimeSwitch()
    public let labelText = LimeText()
    public var view: UIView {
        return self.stack.view
    }
    
    override init() {
        super.init()
        self.stack
            .addView(self.labelText)
            .addView(self.switchView)
    }
    
}
