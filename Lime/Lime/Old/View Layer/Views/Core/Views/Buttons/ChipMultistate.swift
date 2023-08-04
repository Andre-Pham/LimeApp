//
//  ChipMultistate.swift
//  Spell
//
//  Created by Andre Pham on 27/4/2023.
//

import SwiftUI

struct ChipMultistate<T: Any>: View {
    var states: [T]
    var labels: [String]? = nil
    var icons: [SpellIcon]? = nil
    var color: Color = SpellColors.secondaryButtonFill
    var textColor: Color = SpellColors.secondaryButtonText
    var minWidth: CGFloat? = nil
    let onTap: (_ state: T) -> Void
    @State private var index = 0
    private var activeLabel: String? {
        if let labels = self.labels {
            return labels[self.index]
        }
        return nil
    }
    private var activeIcon: SpellIcon? {
        if let icons = self.icons {
            return icons[self.index]
        }
        return nil
    }
    
    var body: some View {
        HStack {
            if let icon = self.activeIcon {
                ZStack {
                    icon
                        .foregroundColor(self.textColor)
                    
                    // Ensure appropriate vertical padding is still added
                    SpellText(text: "|", font: .bodyBold, size: .title5, color: .clear)
                }
            }
            
            if let text = self.activeLabel {
                SpellText(text: text, font: .bodyBold, size: .title5, color: self.textColor)
            }
            
            // Render a circle if no icon and no text is provided
            if self.icons == nil && self.labels == nil {
                SpellText(text: "|", font: .bodyBold, size: .title5, color: .clear)
            }
        }
        .frame(minWidth: self.minWidth)
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(self.color)
        .cornerRadius(SpellCoreGraphics.foregroundCornerRadius)
        .onTapGesture {
            self.incrementIndex()
            self.onTap(self.states[self.index])
        }
        .animateButtonPress()
    }
    
    func incrementIndex() {
        self.index = (self.index + 1)%self.states.count
    }
}

struct ChipMultistate_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .center) {
            ChipMultistate(
                states: [1, 2, 3],
                labels: ["1x", "2x", "3x"],
                icons: nil
            ) { state in
                print(state)
            }
        }
    }
}
