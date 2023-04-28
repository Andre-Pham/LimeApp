//
//  SpellButton.swift
//  Spell
//
//  Created by Andre Pham on 27/4/2023.
//

import SwiftUI

struct SpellButton: View {
    var icon: SpellIcon? = nil
    var text: String? = nil
    var color: Color = SpellColors.primaryButtonFill
    var textColor: Color = SpellColors.primaryButtonText
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            if let icon = self.icon {
                ZStack {
                    icon
                        .foregroundColor(self.textColor)
                    
                    // Ensure appropriate vertical padding is still added
                    SpellText(text: "|", font: .bodyBold, size: .title5, color: .clear)
                }
            }
            
            if let text = self.text {
                SpellText(text: text, font: .bodyBold, size: .title5, color: self.textColor)
            }
            
            // Render a circle if no icon and no text is provided
            if self.icon == nil && self.text == nil {
                SpellText(text: "|", font: .bodyBold, size: .title5, color: .clear)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(self.color)
        .cornerRadius(SpellCoreGraphics.foregroundCornerRadius)
        .onTapGesture {
            self.onTap()
        }
        .animateButtonPress()
    }
}

struct SpellButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .center) {
            SpellButton(text: "Press me!") {
                
            }
        }
    }
}
