import Foundation
import CoreGraphics
import AppKit

let OUTPUT_DIR = "output-04.06.2023-08.20"

func saveImage(url: URL, image: NSImage) {
    // Save image
    guard let imageData = image.tiffRepresentation else {
        // Failed to convert image to TIFF representation
        return
    }

    // Create NSBitmapImageRep from NSData
    guard let imageRep = NSBitmapImageRep(data: imageData) else {
        // Failed to create NSBitmapImageRep
        return
    }

    // Get the raw bitmap data from NSBitmapImageRep
    guard let bitmapData = imageRep.representation(using: .png, properties: [:]) else {
        // Failed to get bitmap data
        return
    }
    
    var urlComponents = url.pathComponents
    urlComponents.remove(at: 0)
    guard let replacementIndex = urlComponents.firstIndex(where: { $0 == OUTPUT_DIR }) else {
        fatalError("Update output dir")
    }
    urlComponents[replacementIndex] = OUTPUT_DIR + "-VALIDATED"
    

    // Create a URL for the output file
    let fileURL = URL(fileURLWithPath: "/" + urlComponents.joined(separator: "/"))

    // Write the bitmap data to the file
    do {
        try bitmapData.write(to: fileURL)
        print("Image saved successfully.")
    } catch {
        print("Error saving image: \(error.localizedDescription)")
    }
}

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
                saveImage(url: imageURL, image: image)
                print("\(path) \(index + 1) (\(image.size.width)x\(image.size.height))")
            }
        } else {
            print("Failed to load image at \(imageURL.path)")
            fatalError()
        }
    }
}
print("FINISHED")
