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
        sceneController.addModel(SceneModel(fileName: "alphabet.dae"))
        self.sceneViewController = SceneViewController()
        self.sceneViewController.attach(scene: sceneController)
        self.sceneViewController.setupScene()
    }
    
    var body: some View {
        ZStack {
            SceneView(self.sceneViewController)
                .ignoresSafeArea()
            
            SceneToolbarView(sceneViewController: self.sceneViewController)
            
            VStack {
                Button("print") {
                    self.sceneViewController.scene.printNames()
                }
                
                Button("camera") {
                    self.sceneViewController.scene.positionCameraFacing(node: .hands)
                }
                
                Button("boxes") {
                    self.sceneViewController.scene.clearGeometry()
                    self.sceneViewController.scene.showBox(for: .hands)
                }
                
                Button("dots") {
                    self.sceneViewController.scene.clearGeometry()
                    self.sceneViewController.scene.showPosition(for: .rightHand, .leftHand)
                }
                
                Button("origin") {
                    let sphere = GeometryBuilder.sphere(position: SCNVector3(), radius: 10.0)
                    let sceneSphere = SceneGeometry(id: "origin", geometry: sphere)
                        .setColor(to: .green)
                        .setOpacity(to: 0.2)
                    self.sceneViewController.scene.addGeometry(sceneSphere)
                }
                
                Spacer()
            }
        }
    }
}

struct Generate3DView_Previews: PreviewProvider {
    static var previews: some View {
        GenerateSceneView()
    }
}
