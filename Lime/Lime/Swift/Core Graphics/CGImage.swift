//
//  CGImage.swift
//  Lime
//
//  Created by Andre Pham on 30/9/2023.
//

import Foundation
import CoreGraphics

extension CGImage {
    
    /// Resizes the image to the specified size.
    /// https://rockyshikoku.medium.com/resize-cgimage-baf23a0f58ab
    ///
    /// - Parameters:
    ///   - size: The new size of the image
    /// - Returns: A new CGImage object with the specified size, or nil if the image could not be resized
    func resize(size: CGSize) -> CGImage? {
        let width: Int = Int(size.width)
        let height: Int = Int(size.height)

        let bytesPerPixel = self.bitsPerPixel / self.bitsPerComponent
        let destBytesPerRow = width * bytesPerPixel

        guard let colorSpace = self.colorSpace else {
            return nil
        }
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: self.bitsPerComponent,
            bytesPerRow: destBytesPerRow,
            space: colorSpace,
            bitmapInfo: self.alphaInfo.rawValue
        ) else {
            return nil
        }

        context.interpolationQuality = .high
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        return context.makeImage()
    }
    
    func scale(toAspectFillSize size: CGSize) -> CGImage? {
        let currentSize = CGRect(origin: CGPoint(), size: CGSize(width: self.width, height: self.height))
        let newSize = currentSize.scale(toAspectFillSize: size)
        return self.resize(size: newSize.size)
    }
    
}
