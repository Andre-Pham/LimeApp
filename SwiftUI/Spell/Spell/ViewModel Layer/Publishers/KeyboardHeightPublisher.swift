//
//  KeyboardHeightPublisher.swift
//  Spell
//
//  Created by Andre Pham on 8/3/2023.
//

import Combine
import UIKit
import SwiftUI

extension Notification {
    
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
    var keyboardDuration: Double {
        return (userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]) as! Double
    }
    var keyboardAnimationCurve: UIView.AnimationCurve {
        return UIView.AnimationCurve(rawValue: (userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int))!
    }
    var keyboardAnimation: Animation {
        let timing = UICubicTimingParameters(animationCurve: self.keyboardAnimationCurve)
        if let springParams = timing.springTimingParameters,
           let mass = springParams.value(forKey: "mass") as? Double, let stiffness = springParams.value(forKey: "stiffness") as? Double, let damping = springParams.value(forKey: "damping") as? Double {
            return Animation.interpolatingSpring(mass: mass, stiffness: stiffness, damping: damping)
        } else {
            return Animation.easeOut(duration: self.keyboardDuration) // this is the closest fallback
        }
    }
    
}

extension Publishers {

    static var keyboardHeightChange: AnyPublisher<(CGFloat, Animation), Never> {
        let keyboardWillShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification).map({
            ($0.keyboardHeight, $0.keyboardAnimation)
        })
        let keyboardWillHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification).map({
            (CGFloat(0), $0.keyboardAnimation)
        })
        return MergeMany(keyboardWillShow, keyboardWillHide).eraseToAnyPublisher()
    }
    
}
