//
//  KeyboardPadding.swift
//  Spell
//
//  Created by Andre Pham on 8/3/2023.
//

import Foundation
import SwiftUI
import Combine

struct KeyboardPadding: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    var padding: Double?
    
    private var activePadding: Double {
        if let padding = self.padding {
            return self.keyboardHeight == 0 ? 0 : padding
        }
        return self.keyboardHeight
    }

    func body(content: Content) -> some View {
        content
            .padding(.bottom, self.activePadding)
            .animation(.interpolatingSpring(stiffness: 80, damping: 100, initialVelocity: 5), value: self.keyboardHeight)
            .onReceive(Publishers.keyboardHeightChange) { height in
                self.keyboardHeight = height
            }
    }
}
extension View {
    func keyboardPadding(padding: Double? = nil) -> some View {
        ModifiedContent(content: self, modifier: KeyboardPadding(padding: padding))
    }
}
