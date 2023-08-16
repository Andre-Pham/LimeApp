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
    private(set) var interpolate = true
    private(set) var hidePrompt = false
    
    init() { }
    
    // MARK: - Serialization
    
    private enum Field: String {
        case leftHanded
        case interpolate
        case hidePrompt
    }
    
    required init(dataObject: DataObject) {
        self.leftHanded = dataObject.get(Field.leftHanded.rawValue, onFail: false)
        self.interpolate = dataObject.get(Field.interpolate.rawValue, onFail: true)
        self.hidePrompt = dataObject.get(Field.hidePrompt.rawValue, onFail: false)
    }
    
    func toDataObject() -> DataObject {
        return DataObject(self)
            .add(key: Field.leftHanded.rawValue, value: self.leftHanded)
            .add(key: Field.interpolate.rawValue, value: self.interpolate)
            .add(key: Field.hidePrompt.rawValue, value: self.hidePrompt)
    }
    
    // MARK: - Functions
    
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
