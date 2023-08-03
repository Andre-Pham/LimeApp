//
//  ScrubberView.swift
//  Spell
//
//  Created by Andre Pham on 27/4/2023.
//

import SwiftUI

struct ScrubberView: View {
    
    /// The progression proportion, between 0 and 1
    @Binding var progressProportion: CGFloat
    /// If the scrubber is currently being adjusted
    @Binding var isTracking: Bool
    /// The diameter of the interactive control
    private static let SCRUBBER_DIAMETER = 30.0
    
    var body: some View {
        GeometryReader { geometry in
            let timelineWidth = geometry.size.width - Self.SCRUBBER_DIAMETER
            
            ZStack {
                RoundedRectangle(cornerRadius: 50, style: .continuous)
                    .frame(width: geometry.size.width, height: Self.SCRUBBER_DIAMETER)
                    .position(x: geometry.size.width/2, y: geometry.size.height/2)
                    .foregroundColor(SpellColors.component)
                
                RoundedRectangle(cornerRadius: 50, style: .continuous)
                    .frame(width: timelineWidth, height: 5)
                    .position(x: geometry.size.width/2, y: geometry.size.height/2)
                    .foregroundColor(.black)
                    .opacity(0.15)
                
                Circle()
                    .fill(SpellColors.accent)
                    .frame(width: Self.SCRUBBER_DIAMETER, height: Self.SCRUBBER_DIAMETER)
                    .position(x: max(0.0, min(self.progressProportion, 1.0))*timelineWidth + Self.SCRUBBER_DIAMETER/2, y: geometry.size.height / 2)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({
                        self.isTracking = true
                        self.progressProportion = min(timelineWidth, max(0, $0.location.x - Self.SCRUBBER_DIAMETER/2))/timelineWidth
                    })
                    .onEnded({ _ in
                        self.isTracking = false
                    })
            )
            .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
        }
    }
}
