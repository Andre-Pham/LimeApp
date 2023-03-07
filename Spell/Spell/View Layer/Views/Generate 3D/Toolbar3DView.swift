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
    
    var body: some View {
        ZStack {
//            Rectangle()
//                .fill(.white)
//                .cornerRadius(50.0)
            
            VStack(alignment: .leading, spacing: 10) {
                if self.promptToolActive {
                    TextField("Enter your name", text: self.$prompt)
                        .padding(16)
                        .background(SpellColors.secondaryButtonFill)
                        .cornerRadius(30)
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
            .cornerRadius(30)
        }
        .padding(.horizontal)
        //.frame(height: 0) // Minimum rect height (expands with content)
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
