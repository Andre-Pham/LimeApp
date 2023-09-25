//
//  WrapsToZero.swift
//  Lime
//
//  Created by Andre Pham on 26/9/2023.
//

import Foundation

@propertyWrapper
struct WrapsToZero {
    private var value: Int
    private let resetThreshold: Int
    
    var wrappedValue: Int {
        get { self.value }
        set {
            self.value = newValue <= self.resetThreshold ? newValue : 0
        }
    }
    
    init(wrappedValue value: Int, threshold: Int) {
        self.value = value
        self.resetThreshold = threshold
    }
}
