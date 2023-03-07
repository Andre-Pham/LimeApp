//
//  ChipToggle.swift
//  Spell
//
//  Created by Andre Pham on 6/3/2023.
//

import SwiftUI

struct ChipToggle: View {
    @State private var isSelected = false
    var icon: SpellIcon? = nil
    let text: String
    let onTap: (_ isSelected: Bool) -> Void
    var color: Color = SpellColors.secondaryButtonFill
    var selectedColor: Color = SpellColors.primaryButtonFill
    var textColor: Color = SpellColors.secondaryButtonText
    var selectedTextColor: Color = SpellColors.primaryButtonText
    
    private var activeColor: Color {
        return self.isSelected ? self.selectedColor : self.color
    }
    private var activeTextColor: Color {
        return self.isSelected ? self.selectedTextColor : self.textColor
    }
    
    var body: some View {
        HStack {
            if let icon = self.icon {
                icon
                    .foregroundColor(self.activeTextColor)
            }
            
            SpellText(text: self.text, font: .bodyBold, size: .title5, color: self.activeTextColor)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(self.activeColor)
        .cornerRadius(50)
        .onTapGesture {
            self.isSelected.toggle()
            self.onTap(self.isSelected)
        }
        .animateButtonPress()
    }
}

struct ChipToggle_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ChipToggle(text: "Hello World") { isSelected in
                print("Chip is selected: \(isSelected)")
            }
            
            ChipToggle(icon: SpellIcon(image: Image(systemName: "trash.fill")), text: "Chip") { isSelected in
                print("Chip is selected: \(isSelected)")
            }
        }
    }
}
