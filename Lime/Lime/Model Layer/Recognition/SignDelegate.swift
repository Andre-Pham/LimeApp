//
//  SignDelegate.swift
//  Lime
//
//  Created by Andre Pham on 7/5/2023.
//

import Foundation

protocol SignDelegate: AnyObject {
    
    func onPrediction(outcome: PredictionOutcome)
    
    func onPredictionPositions(outcome: PredictionOutcome)
    
}
