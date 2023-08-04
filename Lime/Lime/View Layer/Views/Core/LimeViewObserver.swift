//
//  ViewObserver.swift
//  Lime
//
//  Created by Andre Pham on 30/6/2023.
//

import Foundation

protocol LimeViewPublisher: AnyObject {
    
    var subscribers: [WeakLimeViewObserver] { get set }
    
}
extension LimeViewPublisher {
    
    func subscribe(_ subscriber: LimeViewObserver) {
        self.subscribers.append(WeakLimeViewObserver(value: subscriber))
    }
    
    func publish(_ view: LimeUIView) {
        for sub in self.subscribers {
            sub.value?.viewStateDidChange(view)
        }
    }
    
}


protocol LimeViewObserver: AnyObject {
    
    func viewStateDidChange(_ view: LimeUIView)
    
}


class WeakLimeViewObserver {
    
    private(set) weak var value: LimeViewObserver?

    init(value: LimeViewObserver?) {
        self.value = value
    }
    
}
