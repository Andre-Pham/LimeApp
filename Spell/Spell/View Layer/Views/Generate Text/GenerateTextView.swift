//
//  GenerateTextView.swift
//  Spell
//
//  Created by Andre Pham on 6/3/2023.
//

import SwiftUI

struct GenerateTextView: View {
    private let cameraViewController = CameraViewController()
    
    var body: some View {
        ZStack {
            CameraView(self.cameraViewController)
                .ignoresSafeArea()
            
            OverlaidToolbar {
                ToolbarRow {
                    Spacer()

                    ChipToggle(
                        icon: SpellIcon(image: Image(systemName: "arrow.triangle.2.circlepath.camera.fill"))
                    ) { isSelected in
                        self.cameraViewController.flipCamera()
                    }
                }
            }
        }
    }
}
