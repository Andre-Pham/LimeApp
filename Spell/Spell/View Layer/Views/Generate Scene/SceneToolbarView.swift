//
//  SceneToolbarView.swift
//  Spell
//
//  Created by Andre Pham on 7/3/2023.
//

import SwiftUI

struct SceneToolbarView: View {
    
    /// If the prompt tool is visible
    @State private var promptToolActive = false
    /// Prompt text
    @State private var prompt: String = ""
    /// Prompt input text is focused
    @FocusState private var promptFocused: Bool
    
    /// If the current model's animation is playing
    @State private var isPlaying = false
    
    /// If the timeline tool is visible
    @State private var timelineToolActive = false
    /// The scrubber's progression proportion, between 0 and 1
    @State private var scrubberProgressProportion: CGFloat = 0.0
    /// If the scrubber is currently being adjusted
    @State private var isTracking = false
    /// Caches whether the scene is paused or not
    @State private var pauseCache = false
    /// Caches the animation speed of the animation
    @State private var animationSpeedCache = 1.0
    /// The number of tools open
    private var toolsOpenCount: Int {
        let prompt = self.promptToolActive ? 1 : 0
        let timeline = self.timelineToolActive ? 1 : 0
        return prompt + timeline
    }
    
    @State private var isPausedTracker = false
    
    @State private var activeLetter = ""
    
    var body: some View {
        OverlaidToolbar {
            if self.timelineToolActive {
                ToolbarRow {
                    ScrubberView(progressProportion: self.$scrubberProgressProportion, isTracking: self.$isTracking)
                        .frame(height: 25.0)
                        .onChange(of: self.isTracking) { isTracking in
                            if isTracking {
//                                print("MOVING TRACK WHILE PAUSED: \(self.pauseCache)")
                                self.pauseCache = (self.isPausedTracker)
                                SpellSession.inst.sequence?.setSequenceAnimationMultiplier(to: 1.0)
                                self.animationSpeedCache = SpellSession.inst.sequence?.animationSpeed ?? 1.0
                                // The model appears in the starting position during tracking unless playing
                                // Slow down the animation so it appears not to play
                                SpellSession.inst.sequence?.setSequenceAnimationSpeed(to: 0.001)
                                SpellSession.inst.sequence?.playSequence()
                            } else {
                                // Resume state - delay to guarantee model doesn't appear in starting position
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//                                    print("Toolbar setting sequence pause to: \(self.pauseCache)")
//                                    print("SpellSession.inst.sequence?.setSequencePause(to: \(self.pauseCache))")
//                                    print("SpellSession.inst.sequence?.setSequenceAnimationSpeed(to: \(self.animationSpeedCache))")
                                    SpellSession.inst.sequence?.setSequencePause(to: self.pauseCache)
                                    SpellSession.inst.sequence?.setSequenceAnimationSpeed(to: self.animationSpeedCache)
                                    print("> > > > > > > > LET GO OF TIMELINE")
                                }
                            }
                        }
                        .onChange(of: self.scrubberProgressProportion) { proportion in
                            if self.isTracking {
//                                print(">>>> PROPORTION SET TO: \(proportion)")
//                                SpellSession.inst.sequence?.setAnimationTime(to: proportion)
                                let clampedProportion = SpellSession.inst.sequence?.clampToAnimationStart(proportion: proportion) ?? 0.0
                                self.scrubberProgressProportion = clampedProportion
                            }
                        }
                    
                    Spacer()
                    
                    ChipMultistate(
                        states: [1.0, 1.5, 0.25, 0.5],
                        labels: ["1x", "1.5x", "0.25x", "0.5x"],
                        minWidth: 50
                    ) { animationSpeed in
                        SpellSession.inst.sequence?.setSequenceAnimationSpeed(to: animationSpeed)
                    }
                }
            }
            
            if self.promptToolActive {
                ToolbarRow {
                    TextField("Prompt", text: self.$prompt)
                        .submitLabel(.done)
                        .font(SpellTextFont.bodyBold.value(size: .body))
                        .padding(16) // Padding around text
                        .background(SpellColors.secondaryButtonFill)
                        .cornerRadius(SpellCoreGraphics.foregroundCornerRadius)
                        .focused(self.$promptFocused)
                        .onChange(of: self.promptFocused) { isFocused in
                            if isFocused && self.isPlaying {
                                self.isPlaying = false
                            }
                        }
                }
            }
            
            ToolbarRow {
                ChipToggle(
                    icon: SpellIcon(image: Image(systemName: "character.cursor.ibeam"))
                ) { isSelected in
                    self.promptToolActive = isSelected
                }

                ChipToggle(
                    icon: SpellIcon(image: Image(systemName: "slider.horizontal.below.rectangle"))
                ) { isSelected in
                    self.timelineToolActive = isSelected
                }
                
                SpellButton(
                    icon: SpellIcon(image: Image(systemName: "cube.transparent")),
                    color: SpellColors.secondaryButtonFill,
                    textColor: SpellColors.secondaryButtonText
                ) {
                    if let activeModel = SpellSession.inst.sequence?.activeModel {
                        SpellSession.inst.sceneController.positionCameraFacing(model: activeModel)
                    }
                }
                
                Text(self.activeLetter)
                
                Spacer()
                
                BindingChipToggle(
                    isSelected: self.$isPlaying,
                    icon: SpellIcon(image: Image(systemName: "play.fill")),
                    selectedIcon: SpellIcon(image: Image(systemName: "pause.fill"), scale: 0.85),
                    color: SpellColors.primaryButtonFill,
                    textColor: SpellColors.primaryButtonText
                ) { isPlaying in
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    self.isPausedTracker = !isPlaying
                    SpellSession.inst.sequence?.setSequencePause(to: !isPlaying)
                }
            }
        }
        .animation(.interpolatingSpring(stiffness: 60, damping: 60, initialVelocity: 10), value: self.toolsOpenCount)
        .onAppear {
            // TODO: Try this with the SwiftUI timer to see if performance increases
            Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { timer in
                if !self.isTracking, let proportion = SpellSession.inst.sequence?.animationProgressProportion {
                    self.scrubberProgressProportion = proportion
                    self.activeLetter = SpellSession.inst.sequence?.activeModel.name ?? ""
                }
            }
        }
    }
}

struct Toolbar3DView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.green
                .ignoresSafeArea()
            
            SceneToolbarView()
        }
    }
}
