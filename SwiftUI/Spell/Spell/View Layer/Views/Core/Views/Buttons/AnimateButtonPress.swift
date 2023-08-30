//
//  AnimateButtonPress.swift
//  Spell
//
//  Created by Andre Pham on 6/3/2023.
//

import Foundation
import SwiftUI

fileprivate struct AnimateButtonPress: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .opacity(self.isPressed ? 0.7 : 1.0)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            self.isPressed = true
                        }
                    })
                    .onEnded({ _ in
                        withAnimation(.easeInOut(duration: 0.35)) {
                            self.isPressed = false
                        }
                    })
            )
    }
}
extension View {
    func animateButtonPress() -> some View {
        modifier(AnimateButtonPress())
    }
}
