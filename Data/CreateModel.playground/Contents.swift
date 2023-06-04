import Foundation
import CreateML

// Define the path to the folders
let trainingDataURL = URL(fileURLWithPath: "/Users/andrepham/Desktop/Repos/SpellApp/Data/output-04.06.2023-08.20")

// Define parameters for the model
let modelParameters = MLImageClassifier.ModelParameters(validationData: nil, maxIterations: 80, augmentationOptions: .flip)

// Train the image classifier model
let handPoseModel: MLImageClassifier
do {
    handPoseModel = try MLImageClassifier(trainingData: .labeledDirectories(at: trainingDataURL), parameters: modelParameters)
} catch {
    fatalError("Failed to train the model: \(error)")
}

// Evaluate the model
let trainingAccuracy = (1.0 - handPoseModel.trainingMetrics.classificationError) * 100
let validationAccuracy = (1.0 - handPoseModel.validationMetrics.classificationError) * 100
print("Training Accuracy: \(trainingAccuracy)%")
print("Validation Accuracy: \(validationAccuracy)%")

// Save the model
let metadata = MLModelMetadata(author: "Andre Pham", shortDescription: "Auslan pose classifier.", version: "1.0")
do {
    try handPoseModel.write(to: URL(fileURLWithPath: "/Users/andrepham/Desktop/Repos/SpellApp/Data/output.mlmodel"), metadata: metadata)
} catch {
    fatalError("Failed to save the model: \(error)")
}
