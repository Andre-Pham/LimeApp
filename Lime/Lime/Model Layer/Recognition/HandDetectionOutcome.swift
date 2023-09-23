//
//  HandDetectionOutcome.swift
//  Lime
//
//  Created by Andre Pham on 21/9/2023.
//

import Foundation

class HandDetectionOutcome {
    
    private(set) var handDetections = [HandDetection]()
    
    init() { }
    
    func addHandDetection(_ handDetection: HandDetection) {
        self.handDetections.append(handDetection)
    }
    
}
