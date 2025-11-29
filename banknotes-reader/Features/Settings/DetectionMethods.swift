//
//  DetectionMethods.swift
//  banknotes-reader
//
//  Created by Robert Wan on 5/11/2025.
//

struct DetectionMethod {
    let title: String
    let type: UIViewController.Type
}

let detectionMethods: [DetectionMethod] = [
    DetectionMethod(title: "ARKit", type: ARSCNViewController.self),
//    DetectionMethod(title: "Vision", type: VisionViewController.self),
    DetectionMethod(title: "Vuforia", type: VuforiaViewController.self),
    DetectionMethod(title: "Dummy", type: DummyViewController.self)
]
