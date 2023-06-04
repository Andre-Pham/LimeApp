import Foundation
import CreateML
import CoreML

var augmentationParameters = MLHandPoseClassifier.ImageAugmentationOptions()
augmentationParameters.insert(.rotate)
augmentationParameters.insert(.translate)
augmentationParameters.insert(.horizontallyFlip)
augmentationParameters.insert(.scale)

var modelParameters = MLHandPoseClassifier.ModelParameters()
modelParameters.validation = .none
modelParameters.maximumIterations = 80
modelParameters.augmentationOptions = augmentationParameters

let trainingDataURL = URL(fileURLWithPath: "/Users/andrepham/Desktop/Repos/SpellApp/Data/Training/output-04.06.2023-08.20")
let trainingDataSource: MLHandPoseClassifier.DataSource = MLHandPoseClassifier.DataSource.labeledDirectories(at: trainingDataURL)
let model: MLHandPoseClassifier
do {
    model = try MLHandPoseClassifier(trainingData: trainingDataSource, parameters: modelParameters)
} catch {
    fatalError("Failed to train the model: \(error)")
}

let trainingAccuracy = (1.0 - model.trainingMetrics.classificationError) * 100
let validationAccuracy = (1.0 - model.validationMetrics.classificationError) * 100
print("Training Accuracy: \(trainingAccuracy)%")
print("Validation Accuracy: \(validationAccuracy)%")

let metadata = MLModelMetadata(author: "Andre Pham", shortDescription: "Auslan pose classifier.", version: "1.0")
do {
    try model.write(to: URL(fileURLWithPath: "/Users/andrepham/Desktop/Repos/SpellApp/Data/AuslanClassifier.mlmodel"), metadata: metadata)
} catch {
    fatalError("Failed to save the model: \(error)")
}
