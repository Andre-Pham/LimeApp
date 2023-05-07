//
//  SignDelegate.swift
//  Spell
//
//  Created by Andre Pham on 7/5/2023.
//

import Foundation

protocol SignDelegate: AnyObject {
    
    func onPrediction(outcome: Label)
    
    func onPredictionPositions(outcome: Label, positions: JointPositions)
    
}
