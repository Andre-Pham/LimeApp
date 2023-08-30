//
//  LimeGestureView.swift
//  Lime
//
//  Created by Andre Pham on 5/8/2023.
//

import Foundation
import UIKit

class LimeGestureView: LimeUIView {
    
    public let view: UIView
    
    override init() {
        self.view = GestureUIView()
        super.init()
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @discardableResult
    func setOnGesture(_ callback: ((_ gesture: UIPanGestureRecognizer) -> Void)?) -> Self {
        (self.view as! GestureUIView).onGesture = callback
        return self
    }
    
}

fileprivate class GestureUIView: UIView {
    
    public var onGesture: ((_ gesture: UIPanGestureRecognizer) -> Void)? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
        self.addGestureRecognizer(panGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        self.onGesture?(gesture)
    }
    
}
