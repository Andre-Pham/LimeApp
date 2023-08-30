//
//  Toolbar.swift
//  Spell
//
//  Created by Andre Pham on 18/4/2023.
//

import SwiftUI

struct Toolbar<Content: View>: View {
    private let content: () -> Content
    
    init(@ViewBuilder builder: @escaping () -> Content) {
        self.content = builder
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            self.content()
        }
        .frame(maxWidth: .infinity)
        .padding(15) // Padding around components inside toolbar
        .background(SpellColors.toolbarFill)
        .cornerRadius(SpellCoreGraphics.backgroundCornerRadius)
        .keyboardPadding(padding: 260)
    }
}
