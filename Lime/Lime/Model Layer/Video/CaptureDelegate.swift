//
//  CaptureDelegate.swift
//  Lime
//
//  Created by Andre Pham on 12/4/2023.
//

import Foundation
import CoreVideo

protocol CaptureDelegate: AnyObject {
    
    func onCapture(session: CaptureSession, frame: CGImage?)
    
}
