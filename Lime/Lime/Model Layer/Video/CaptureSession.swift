//
//  CaptureSession.swift
//  Lime
//
//  Created by Andre Pham on 12/4/2023.
//

import Foundation
import AVFoundation
import CoreVideo
import UIKit
import VideoToolbox

class CaptureSession: NSObject {
    
    enum CaptureError: Error {
        case captureSessionIsMissing
        case invalidInput
        case invalidOutput
        case unknown
    }
    
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var cameraPosition = AVCaptureDevice.Position.front
    private let sessionQueue = DispatchQueue(label: "andrepham.Lime.sessionqueue")
    public weak var captureDelegate: CaptureDelegate?
    
    public func flipCamera(completion: @escaping (Error?) -> Void) {
        self.sessionQueue.async {
            do {
                self.cameraPosition = self.cameraPosition == .back ? .front : .back

                // Indicate the start of a set of configuration changes to the capture session.
                self.captureSession.beginConfiguration()

                try self.setCaptureSessionInput()
                try self.setCaptureSessionOutput()

                // Commit configuration changes.
                self.captureSession.commitConfiguration()

                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    public func setUpAVCapture(completion: @escaping (Error?) -> Void) {
        self.sessionQueue.async {
            do {
                try self.setUpAVCapture()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    private func setUpAVCapture() throws {
        if self.captureSession.isRunning {
            self.captureSession.stopRunning()
        }
        self.captureSession.beginConfiguration()
        self.captureSession.sessionPreset = .vga640x480
        try setCaptureSessionInput()
        try setCaptureSessionOutput()
        self.captureSession.commitConfiguration()
    }
    
    private func setCaptureSessionInput() throws {
        guard let captureDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: AVMediaType.video,
            position: self.cameraPosition
        ) else {
            throw CaptureError.invalidInput
        }

        // Remove any existing inputs.
        self.captureSession.inputs.forEach { input in
            self.captureSession.removeInput(input)
        }

        // Create an instance of AVCaptureDeviceInput to capture the data from
        // the capture device.
        guard let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            throw CaptureError.invalidInput
        }

        guard captureSession.canAddInput(videoInput) else {
            throw CaptureError.invalidInput
        }

        self.captureSession.addInput(videoInput)
    }
    
    private func setCaptureSessionOutput() throws {
        // Remove any previous outputs.
        captureSession.outputs.forEach { output in
            captureSession.removeOutput(output)
        }

        // Set the pixel type.
        let settings: [String: Any] = [
            String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        ]

        self.videoOutput.videoSettings = settings

        // Discard newer frames that arrive while the dispatch queue is already busy with
        // an older frame.
        self.videoOutput.alwaysDiscardsLateVideoFrames = true

        self.videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)

        guard captureSession.canAddOutput(videoOutput) else {
            throw CaptureError.invalidOutput
        }

        self.captureSession.addOutput(self.videoOutput)

        // Update the video orientation
        if let connection = self.videoOutput.connection(with: .video), connection.isVideoOrientationSupported {
            switch UIDevice.current.orientation {
            case .unknown, .portrait, .faceUp, .faceDown:
                connection.videoOrientation = .portrait
            case .portraitUpsideDown:
                connection.videoOrientation = .portraitUpsideDown
            case .landscapeLeft:
                // Inverse to force the image in the upward orientation
                connection.videoOrientation = .landscapeRight
            case .landscapeRight:
                // Inverse to force the image in the upward orientation
                connection.videoOrientation = .landscapeLeft
            @unknown default:
                assertionFailure("Implement newly added orientation")
            }
            connection.isVideoMirrored = self.cameraPosition == .front
        }
    }
    
    public func startCapturing(completion completionHandler: (() -> Void)? = nil) {
        self.sessionQueue.async {
            if !self.captureSession.isRunning {
                // Invoke the startRunning method of the captureSession to start the
                // flow of data from the inputs to the outputs.
                self.captureSession.startRunning()
            }

            if let completionHandler = completionHandler {
                DispatchQueue.main.async {
                    completionHandler()
                }
            }
        }
    }
    
    public func stopCapturing(completion completionHandler: (() -> Void)? = nil) {
        self.sessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }

            if let completionHandler = completionHandler {
                DispatchQueue.main.async {
                    completionHandler()
                }
            }
        }
    }
    
}

extension CaptureSession: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput,
                              didOutput sampleBuffer: CMSampleBuffer,
                              from connection: AVCaptureConnection) {
        guard let captureDelegate = self.captureDelegate else { return }

        if let pixelBuffer = sampleBuffer.imageBuffer {
            // Attempt to lock the image buffer to gain access to its memory.
            guard CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) == kCVReturnSuccess
                else {
                    return
            }

            // Create Core Graphics image placeholder.
            var image: CGImage?

            // Create a Core Graphics bitmap image from the pixel buffer.
            VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &image)

            // Release the image buffer.
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)

            DispatchQueue.main.sync {
                captureDelegate.onCapture(session: self, frame: image)
            }
        }
    }
    
}
