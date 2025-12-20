//
//  Constants.swift
//  banknotes-reader
//
//  Created by Robert Wan on 5/11/2025.
//

struct DetectionMethod {
    let title: String
    let type: UIViewController.Type
}

let detectionMethods: [DetectionMethod] = [
    DetectionMethod(title: "ARKit", type: ARKitViewController.self),
//    DetectionMethod(title: "Vision", type: VisionViewController.self),
    DetectionMethod(title: "Vuforia", type: VuforiaViewController.self),
    DetectionMethod(title: "Dummy", type: DummyViewController.self)
]

struct Language {
    let title: String
    let code: String
    let voice: String
}

let languages: [Language] = [
    Language(title: "English", code: "en", voice: "en"),
    Language(title: "繁體中文", code: "zh-Hant", voice: "zh")
]
