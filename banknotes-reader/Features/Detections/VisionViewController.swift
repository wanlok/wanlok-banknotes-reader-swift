//
//  VisionViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 31/10/2025.
//

import UIKit
import Vision

struct ReferenceImage {
    let name: String
    let featurePrint: VNFeaturePrintObservation
}

func createReferenceFeaturePrints() -> [ReferenceImage] {
    let imageNames = ["AUD_50", "AUD_100"]
    var referenceImages: [ReferenceImage] = []

    for name in imageNames {
        guard let uiImage = UIImage(named: name),
              let cgImage = uiImage.cgImage else { continue }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNGenerateImageFeaturePrintRequest()
        try? requestHandler.perform([request])

        if let observation = request.results?.first as? VNFeaturePrintObservation {
            referenceImages.append(ReferenceImage(name: name, featurePrint: observation))
        }
    }

    return referenceImages
}

func matchImage(_ image: UIImage, with references: [ReferenceImage]) -> String? {
    guard let cgImage = image.cgImage else { return nil }

    let handler = VNImageRequestHandler(cgImage: cgImage)
    let request = VNGenerateImageFeaturePrintRequest()
    try? handler.perform([request])

    guard let targetObservation = request.results?.first as? VNFeaturePrintObservation else {
        return nil
    }

    var bestMatchName: String?
    var smallestDistance: Float = .greatestFiniteMagnitude

    for reference in references {
        var distance: Float = 0
        try? targetObservation.computeDistance(&distance, to: reference.featurePrint)
        if distance < smallestDistance {
            smallestDistance = distance
            bestMatchName = reference.name
        }
    }

    if smallestDistance < 30.0 {
        return bestMatchName
    } else {
        return nil
    }
}

class VisionViewController: CameraViewController {
    var referenceImages: [ReferenceImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        referenceImages = createReferenceFeaturePrints()
        setupCameraView(cameraView)
    }
    
    override func imageCaptured(_ image: UIImage) {
        super.imageCaptured(image)
        
        if let imageName = matchImage(image, with: referenceImages) {
            print("found \(imageName)")
        } else {
            print("image not found")
        }
    }
}
