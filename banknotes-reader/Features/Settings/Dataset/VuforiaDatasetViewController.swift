//
//  VuforiaDatasetViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 29/11/2025.
//

import UIKit

class VuforiaDatasetViewController: DatasetViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        reload()
    }
    
    @objc override func onSyncButtonClicked() {
        activityIndicator.isHidden = false
        tableView.isHidden = true
        let (xmlFilePath, datFilePath) = getVuforiaDatasetFilePaths()
        downloadFiles([
            (url: "https://wanlok.github.io/\(vuforiaDatasetFileName).xml", filePath: xmlFilePath),
            (url: "https://wanlok.github.io/\(vuforiaDatasetFileName).dat", filePath: datFilePath)
        ]) {
            self.reload()
        }
    }
    
    func reload() {
        let (filePath, _) = getVuforiaDatasetFilePaths()
        let values = getXMLAttributeValues(filePath: filePath, elementName: "ImageTarget", attributeNames: ["name", "size"])
        guard let names = values["name"], let sizes = values["size"] else {
            activityIndicator.isHidden = true
            tableView.isHidden = false
            return
        }
        var rows: [DatasetRow] = []
        for i in 0..<names.count {
            let slices = sizes[i].split(separator: " ")
            if slices.count >= 2 {
                let width = Double(slices[0])
                let height = Double(slices[1])
                if let width = width, let height = height {
                    rows.append(DatasetRow(
                        key: nil,
                        banknote: Banknote(name: names[i], url: nil, width: width, height: height),
                        imageData: nil
                    ))
                }
            }
        }
        sections = [(title: "Dataset", rows: rows)]
        tableView.reloadData()
        activityIndicator.isHidden = true
        tableView.isHidden = false
    }
}
