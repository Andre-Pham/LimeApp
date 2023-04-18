//
//  ToolbarRow.swift
//  Spell
//
//  Created by Andre Pham on 18/4/2023.
//

import SwiftUI

struct ToolbarRow<Content: View>: View {
    private let content: () -> Content
    
    init(@ViewBuilder builder: @escaping () -> Content) {
        self.content = builder
    }
    
    var body: some View {
        HStack {
            self.content()
        }
        .frame(maxWidth: .infinity)
    }
}
