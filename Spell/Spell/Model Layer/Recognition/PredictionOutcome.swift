//
//  PredictionOutcome.swift
//  Spell
//
//  Created by Andre Pham on 1/6/2023.
//

import Foundation

class PredictionOutcome {
    
    private(set) var hand1Outcome: Label = .none
    private(set) var hand2Outcome: Label = .none
    private(set) var hand1Positions = JointPositions()
    private(set) var hand2Positions = JointPositions()
    
    func setHandOutcome(hand: Int, label: Label) {
        assert([0, 1].contains(hand), "Hands indices can only be 0 or 1")
        if hand == 0 {
            self.hand1Outcome = label
        } else if hand == 1 {
            self.hand2Outcome = label
        }
    }
    
    func setHandPosition(hand: Int, positions: JointPositions) {
        assert([0, 1].contains(hand), "Hands indices can only be 0 or 1")
        if hand == 0 {
            self.hand1Positions = positions
        } else if hand == 1 {
            self.hand2Positions = positions
        }
    }
    
}
