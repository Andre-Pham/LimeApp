//
//  LimeView.swift
//  Lime
//
//  Created by Andre Pham on 14/6/2023.
//

import Foundation
import UIKit

class LimeView: LimeUIView {
    
    public let view: UIView
    
    override init() {
        self.view = UIView()
        super.init()
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    init(_ view: UIView) {
        self.view = view
    }
    
}
