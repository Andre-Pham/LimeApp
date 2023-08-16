//
//  LimeSettings.swift
//  Lime
//
//  Created by Andre Pham on 16/8/2023.
//

import Foundation

class LimeSettings: Clonable {
    
    private(set) var leftHanded = false
    private(set) var interpolate = true
    private(set) var hidePrompt = false
    
    init() { }
    
    required init(_ original: LimeSettings) {
        self.leftHanded = original.leftHanded
        self.interpolate = original.interpolate
        self.hidePrompt = original.hidePrompt
    }
    
    func setLeftHandedSetting(to state: Bool) {
        self.leftHanded = state
    }
    
    func setInterpolateSetting(to state: Bool) {
        self.interpolate = state
    }
    
    func setHidePromptSetting(to state: Bool) {
        self.hidePrompt = state
    }
    
    func isEquivalent(to other: LimeSettings) -> Bool {
        return (
            self.leftHanded == other.leftHanded &&
            self.interpolate == other.interpolate &&
            self.hidePrompt == other.hidePrompt
        )
    }
    
}
