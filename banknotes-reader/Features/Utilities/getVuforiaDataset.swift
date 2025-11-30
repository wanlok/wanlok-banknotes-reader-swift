//
//  getVuforiaDataset.swift
//  banknotes-reader
//
//  Created by Robert Wan on 30/11/2025.
//

let vuforiaDatasetFileName = "banknotesReader"

func getVuforiaDatasetFilePaths() -> (xml: URL, dat: URL) {
    let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    return (
        xml: documents.appendingPathComponent("\(vuforiaDatasetFileName).xml"),
        dat: documents.appendingPathComponent("\(vuforiaDatasetFileName).dat")
    )
}
