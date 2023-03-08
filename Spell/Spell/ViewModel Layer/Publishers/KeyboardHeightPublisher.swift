//
//  KeyboardHeightPublisher.swift
//  Spell
//
//  Created by Andre Pham on 8/3/2023.
//

import Combine
import UIKit

extension Notification {
    
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
    
}

extension Publishers {

    static var keyboardHeightChange: AnyPublisher<CGFloat, Never> {
        let keyboardWillShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification).map({ $0.keyboardHeight })
        let keyboardWillHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification).map({ _ in CGFloat(0) })
        return MergeMany(keyboardWillShow, keyboardWillHide).eraseToAnyPublisher()
    }
    
}
