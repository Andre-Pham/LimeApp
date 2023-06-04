import Foundation
import CoreGraphics
import AppKit

// Define the path to the image directory
let root = "/Users/andrepham/Desktop/Repos/SpellApp/Data/Training/output-04.06.2023-08.20/"
let paths = [
    "background",
    "c-shape-inwards",
    "closed-hand-inwards",
    "index-hook-inwards",
    "index-middle-point-inwards",
    "index-middle-ring-point-inwards",
    "index-point-inwards",
    "open-hand-inwards",
    "peace-inwards",
    "pinch-indwards",
    "pinky-hook-inwards",
    "spread-hand-inwards"
]

for path in paths {
    let imagesDirectoryPath = root + path
    
    // Get all file URLs in the directory
    let fileManager = FileManager.default
    let imageURLs = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: imagesDirectoryPath), includingPropertiesForKeys: nil)

    // Iterate over each image and check its dimensions
    for (index, imageURL) in imageURLs.enumerated() {
        if let image = NSImage(contentsOf: imageURL) {
            if image.size.width == 0 || image.size.height == 0 {
                print("Found zero-dimensioned image at \(imageURL.path)")
                fatalError()
            } else if !image.isValid {
                print("Found invalid image at \(imageURL.path)")
                fatalError()
            } else if image.size.width != 1920.0 || image.size.height != 1080.0 {
                print("Found dodgy image at \(imageURL.path)")
                fatalError()
            } else {
                print("\(path) \(index + 1) (\(image.size.width)x\(image.size.height))")
            }
        } else {
            print("Failed to load image at \(imageURL.path)")
            fatalError()
        }
    }
}
print("FINISHED")
