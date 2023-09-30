//
//  HandDetectionDelegate.swift
//  Lime
//
//  Created by Andre Pham on 21/9/2023.
//

import Foundation

protocol HandDetectionDelegate: AnyObject {
    
    func onHandDetection(outcome: HandDetectionOutcome?)
    
}
