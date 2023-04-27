//
//  SceneToolbarView.swift
//  Spell
//
//  Created by Andre Pham on 7/3/2023.
//

import SwiftUI

struct SceneToolbarView: View {
    let sceneViewController: SceneViewController
    @State private var promptToolActive = false
    @State private var prompt: String = ""
    @State private var promptDisabled = false
    @State private var promptTimerID = 1
    
    var body: some View {
        OverlaidToolbar {
            if self.promptToolActive {
                ToolbarRow {
                    TextField("Prompt", text: self.$prompt)
                        .disabled(self.promptDisabled)
                        .submitLabel(.done)
                        .font(SpellTextFont.bodyBold.value(size: .body))
                        .padding(16) // Padding around text
                        .background(SpellColors.secondaryButtonFill)
                        .cornerRadius(SpellCoreGraphics.foregroundCornerRadius)
                }
            }
            
            ToolbarRow {
                ChipToggle(icon: SpellIcon(image: Image(systemName: "character.cursor.ibeam"))) { isSelected in
                    self.promptToolActive = isSelected
                    if isSelected {
                        // Disable the prompt to avoid keyboard animation
                        // Animation clashes cause funky behaviour
                        self.promptTimerID = (self.promptTimerID + 1)%1000
                        let localTimerID = self.promptTimerID
                        //self.promptDisabled = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                            if localTimerID == self.promptTimerID {
                                self.promptDisabled = false
                            }
                        }
                    }
                }

                ChipToggle(icon: SpellIcon(image: Image(systemName: "slider.horizontal.below.rectangle"))) { isSelected in
                    
                }
                
                ChipToggle(icon: SpellIcon(image: Image(systemName: "cube.transparent"))) { isSelected in
                    
                }
                
                Spacer()
                
                ChipToggle(
                    icon: SpellIcon(image: Image(systemName: "play.fill")),
                    selectedIcon: SpellIcon(image: Image(systemName: "pause.fill"), scale: 0.85),
                    color: SpellColors.primaryButtonFill,
                    textColor: SpellColors.primaryButtonText
                ) { isPlaying in
                    self.sceneViewController.scene.setScenePause(to: !isPlaying)
                }
            }
        }
        .animation(.interpolatingSpring(stiffness: 60, damping: 60, initialVelocity: 10), value: self.promptToolActive)
    }
}

struct Toolbar3DView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.green
                .ignoresSafeArea()
            
            SceneToolbarView(sceneViewController: SceneViewController())
        }
    }
}