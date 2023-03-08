//
//  Toolbar3DView.swift
//  Spell
//
//  Created by Andre Pham on 7/3/2023.
//

import SwiftUI

struct Toolbar3DView: View {
    @State private var promptToolActive = false
    @State private var prompt: String = ""
    private static let cornerRadius = 30.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if self.promptToolActive {
                TextField("Prompt", text: self.$prompt)
                    .font(SpellTextFont.bodyBold.value(size: .body))
                    .padding(16) // Padding around text
                    .background(SpellColors.secondaryButtonFill)
                    .cornerRadius(Self.cornerRadius)
            }
            
            HStack {
                ChipToggle(icon: SpellIcon(image: Image(systemName: "character.cursor.ibeam"))) { isSelected in
                    self.promptToolActive = isSelected
                }

                ChipToggle(icon: SpellIcon(image: Image(systemName: "slider.horizontal.below.rectangle"))) { isSelected in
                    // Do something
                }
                
                ChipToggle(icon: SpellIcon(image: Image(systemName: "cube.transparent"))) { isSelected in
                    // Do something
                }
                
                Spacer()
                
                ChipToggle(
                    icon: SpellIcon(image: Image(systemName: "play.fill")),
                    selectedIcon: SpellIcon(image: Image(systemName: "pause.fill"), scale: 0.85),
                    color: SpellColors.primaryButtonFill,
                    textColor: SpellColors.primaryButtonText
                ) { isSelected in
                    // Do something
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(15) // Padding around components inside toolbar
        .background(SpellColors.toolbarFill)
        .cornerRadius(Self.cornerRadius)
        .animation(.interpolatingSpring(stiffness: 60, damping: 60, initialVelocity: 10), value: self.promptToolActive)
        .keyboardPadding(padding: 260)
    }
}

struct Toolbar3DView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.green
                .ignoresSafeArea()
            
            Toolbar3DView()
        }
    }
}
