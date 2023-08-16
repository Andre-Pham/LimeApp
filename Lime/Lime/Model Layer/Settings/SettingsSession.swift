//
//  SettingsSession.swift
//  Lime
//
//  Created by Andre Pham on 16/8/2023.
//

import Foundation

class SettingsSession {
    
    /// Singleton instance
    public static let inst = SettingsSession()
    
    private var storedSettings = LimeSettings()
    private var editedSettings: LimeSettings? = nil
    public var isEditing: Bool {
        return self.editedSettings != nil && !self.settingsMatch
    }
    public var settings: LimeSettings {
        if let editedSettings {
            return editedSettings
        } else {
            let new = self.storedSettings.clone()
            self.editedSettings = new
            return new
        }
    }
    private var settingsMatch: Bool {
        return self.editedSettings?.isEquivalent(to: self.storedSettings) ?? true
    }
    
    private init() { }
    
    func applySettings() {
        guard let editedSettings else {
            return
        }
        OnSettingsChangedPublisher.publish(old: self.storedSettings, new: editedSettings)
        // TODO: Write settings to storage
        
        self.storedSettings = editedSettings
        self.editedSettings = nil
    }
    
    func cancelChanges() {
        self.editedSettings = nil
    }
    
}
