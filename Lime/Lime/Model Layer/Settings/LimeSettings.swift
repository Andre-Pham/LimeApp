//
//  LimeSettings.swift
//  Lime
//
//  Created by Andre Pham on 16/8/2023.
//

import Foundation
import SwiftSerialization

class LimeSettings: Storable, Clonable {
    
    private(set) var leftHanded = false
    private(set) var smoothTransitions = true
    private(set) var hidePrompt = false
    
    init() { }
    
    // MARK: - Serialization
    
    private enum Field: String {
        case leftHanded
        case smoothTransitions
        case hidePrompt
    }
    
    required init(dataObject: DataObject) {
        self.leftHanded = dataObject.get(Field.leftHanded.rawValue, onFail: false)
        self.smoothTransitions = dataObject.get(Field.smoothTransitions.rawValue, onFail: true)
        self.hidePrompt = dataObject.get(Field.hidePrompt.rawValue, onFail: false)
    }
    
    func toDataObject() -> DataObject {
        return DataObject(self)
            .add(key: Field.leftHanded.rawValue, value: self.leftHanded)
            .add(key: Field.smoothTransitions.rawValue, value: self.smoothTransitions)
            .add(key: Field.hidePrompt.rawValue, value: self.hidePrompt)
    }
    
    // MARK: - Functions
    
    required init(_ original: LimeSettings) {
        self.leftHanded = original.leftHanded
        self.smoothTransitions = original.smoothTransitions
        self.hidePrompt = original.hidePrompt
    }
    
    func setLeftHandedSetting(to state: Bool) {
        self.leftHanded = state
    }
    
    func setSmoothTransitionsSetting(to state: Bool) {
        self.smoothTransitions = state
    }
    
    func setHidePromptSetting(to state: Bool) {
        self.hidePrompt = state
    }
    
    func isEquivalent(to other: LimeSettings) -> Bool {
        return (
            self.leftHanded == other.leftHanded &&
            self.smoothTransitions == other.smoothTransitions &&
            self.hidePrompt == other.hidePrompt
        )
    }
    
}
