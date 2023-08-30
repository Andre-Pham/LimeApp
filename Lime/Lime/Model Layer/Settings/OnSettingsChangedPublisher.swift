//
//  OnSettingsChangedPublisher.swift
//  Lime
//
//  Created by Andre Pham on 16/8/2023.
//

import Foundation

class OnSettingsChangedPublisher {
    
    static private var subscribers = [WeakOnSettingsChangedSubscriber]()
    
    static func subscribe(_ subscriber: OnSettingsChangedSubscriber) {
        self.subscribers.append(WeakOnSettingsChangedSubscriber(value: subscriber))
    }
    
    static func publish(old: LimeSettings, new: LimeSettings) {
        for sub in Self.subscribers {
            sub.value?.onSettingsChanged(old: old, new: new)
        }
    }
    
}

protocol OnSettingsChangedSubscriber: AnyObject {
    
    func onSettingsChanged(old: LimeSettings, new: LimeSettings)
    
}

private class WeakOnSettingsChangedSubscriber {
    
    private(set) weak var value: OnSettingsChangedSubscriber?

    init(value: OnSettingsChangedSubscriber?) {
        self.value = value
    }
    
}
