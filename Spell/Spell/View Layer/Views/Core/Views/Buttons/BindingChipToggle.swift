//
//  BindingChipToggle.swift
//  Spell
//
//  Created by Andre Pham on 17/5/2023.
//

import SwiftUI

struct BindingChipToggle: View {
    @Binding var isSelected: Bool
    var icon: SpellIcon? = nil
    var selectedIcon: SpellIcon? = nil
    var text: String? = nil
    var color: Color = SpellColors.secondaryButtonFill
    var selectedColor: Color = SpellColors.primaryButtonFill
    var textColor: Color = SpellColors.secondaryButtonText
    var selectedTextColor: Color = SpellColors.primaryButtonText
    let onTap: (_ isSelected: Bool) -> Void
    
    private var activeColor: Color {
        return self.isSelected ? self.selectedColor : self.color
    }
    private var activeTextColor: Color {
        return self.isSelected ? self.selectedTextColor : self.textColor
    }
    private var activeIcon: SpellIcon? {
        if self.isSelected {
            return self.selectedIcon ?? self.icon
        }
        return self.icon
    }
    
    var body: some View {
        HStack {
            if let icon = self.activeIcon {
                ZStack {
                    icon
                        .foregroundColor(self.activeTextColor)
                    
                    // Ensure appropriate vertical padding is still added
                    SpellText(text: "|", font: .bodyBold, size: .title5, color: .clear)
                }
            }
            
            if let text = self.text {
                SpellText(text: text, font: .bodyBold, size: .title5, color: self.activeTextColor)
            }
            
            // Render a circle if no icon and no text is provided
            if self.activeIcon == nil && self.text == nil {
                SpellText(text: "|", font: .bodyBold, size: .title5, color: .clear)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(self.activeColor)
        .cornerRadius(SpellCoreGraphics.foregroundCornerRadius)
        .onTapGesture {
            self.isSelected.toggle()
            self.onTap(self.isSelected)
        }
        .animateButtonPress()
    }
}
