//
//  GenerateSceneView.swift
//  Spell
//
//  Created by Andre Pham on 6/3/2023.
//

import SwiftUI
import SceneKit

struct GenerateSceneView: View {
    private let sceneViewController: SceneViewController
    
    init() {
        let sceneController = SceneController()
        sceneController.addModel(SceneModel(file: "Models.scnassets/alphabet.dae"))
        self.sceneViewController = SceneViewController()
        self.sceneViewController.attach(scene: sceneController)
    }
    
    var body: some View {
        ZStack {
            SceneView(self.sceneViewController)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                SceneToolbarView(sceneViewController: self.sceneViewController)
                    .padding(.horizontal, 15)
                    .padding(.bottom, 20)
            }
        }
    }
}

struct Generate3DView_Previews: PreviewProvider {
    static var previews: some View {
        GenerateSceneView()
    }
}
