//
//  SpellText.swift
//  Spell
//
//  Created by Andre Pham on 6/3/2023.
//

import SwiftUI

struct SpellText: View {
    let text: String
    let font: SpellTextFont
    let size: SpellTextSize
    var color: Color = SpellColors.bodyText
    var multilineTextAlignment: TextAlignment = .leading
    
    var body: some View {
        Text(self.text)
            .font(self.font.value(size: self.size))
            .foregroundColor(self.color)
            .multilineTextAlignment(self.multilineTextAlignment)
            .fixedSize(horizontal: false, vertical: true) // Text wraps instead of being cut off
    }
}

struct SpellText_Previews: PreviewProvider {
    static var previews: some View {
        SpellText(text: "Hello World", font: .title, size: .title5)
    }
}
