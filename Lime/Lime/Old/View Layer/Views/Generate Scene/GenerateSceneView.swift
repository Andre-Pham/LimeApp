//
//  GenerateSceneView.swift
//  Spell
//
//  Created by Andre Pham on 6/3/2023.
//

import SwiftUI
import SceneKit

struct GenerateSceneView: View {
    
    init() {
        SpellSession.inst.addInterpolatedLetterSequence(prompt: "abcd")
    }
    
    var body: some View {
        ZStack {
            //SceneView(SpellSession.inst.sceneViewController)
                //.ignoresSafeArea()
            
            SceneToolbarView()
            
            VStack {
                Button("print") {
                    SpellSession.inst.sceneController.printNames()
                }
                
                Button("camera") {
                    if let activeModel = SpellSession.inst.sequence?.activeModel {
                        SpellSession.inst.sceneController.positionCameraFacing(model: activeModel)
                    }
                }
                
                Button("boxes") {
                    if let activeModel = SpellSession.inst.sequence?.activeModel { SpellSession.inst.sceneController.clearGeometry()
                        SpellSession.inst.sceneController.showBox(for: activeModel)
                    }
                }
                
                Button("dots") {
                    SpellSession.inst.sceneController.clearGeometry()
                    SpellSession.inst.sceneController.showPosition(for: .rightHand, .leftHand)
                }
                
                Button("origin") {
                    let sphere = GeometryBuilder.sphere(position: SCNVector3(), radius: 0.5)
                    let sceneSphere = SceneGeometry(id: "origin", geometry: sphere)
                        .setColor(to: .green)
                        .setOpacity(to: 0.2)
                    SpellSession.inst.sceneController.addGeometry(sceneSphere)
                }
                
                Button("positions") {
                    if let activeModel = SpellSession.inst.sequence?.activeModel { SpellSession.inst.sceneController.clearGeometry()
                        print(activeModel.getRotationsIndex().getRotation(nodeName: "f_index-01-L")!.toString())
                    }
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
