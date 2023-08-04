//
//  OverlaidToolbar.swift
//  Spell
//
//  Created by Andre Pham on 18/4/2023.
//

import Foundation
import SwiftUI

struct OverlaidToolbar<Content: View>: View {
    private let content: () -> Content
    
    init(@ViewBuilder builder: @escaping () -> Content) {
        self.content = builder
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
            
            Toolbar {
                self.content()
            }
            .padding(.horizontal, 15)
            .padding(.bottom, 20)
        }
    }
}
