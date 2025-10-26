//
//  Settings.swift
//  banknotes-reader
//
//  Created by Robert Wan on 26/10/2025.
//

import Foundation

struct Settings {
    static let landing: [(title: String, items: [String])] = [
        (title: "Settings", items: ["Detection Methods", "B"]),
        (title: "Voice", items: ["A", "B"]),
        (title: "About", items: ["A", "B"])
    ]
    
    static let detectionMethods: [(title: String, items: [String])] = [
        (title: "Libraries", items: ["ARKit"])
    ]
}
