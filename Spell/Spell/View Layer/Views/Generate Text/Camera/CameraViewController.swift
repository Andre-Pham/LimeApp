//
//  CameraViewController.swift
//  Spell
//
//  Created by Andre Pham on 12/4/2023.
//

import Foundation
import UIKit
import AVFoundation

class CameraViewController: UIViewController, CaptureDelegate {
    
    private let captureSession = CaptureSession()
    private var currentFrame: CGImage? = nil
    
    override func viewDidLoad() {
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Load model here
        
        self.setupAndBeginCapturingVideoFrames()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.captureSession.stopCapturing {
            super.viewWillDisappear(animated)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // React to change in device orientation
        self.setupAndBeginCapturingVideoFrames()
    }
    
    func onCapture(session: CaptureSession, frame: CGImage?) {
        if let frame {
            self.currentFrame = frame
            
            // Run ML here and delegate the outcome
            
            self.view = UIImageView(image: UIImage(cgImage: frame))
        }
    }
    
    func flipCamera() {
        self.captureSession.flipCamera { error in
            if let error {
                assertionFailure("Failed to flip camera: \(error)")
                return
            }
        }
    }
    
    private func setupAndBeginCapturingVideoFrames() {
        self.captureSession.setUpAVCapture { error in
            if let error {
                assertionFailure("Failed to setup camera: \(error)")
                return
            }
            
            self.captureSession.captureDelegate = self
            self.captureSession.startCapturing()
        }
    }
    
}
