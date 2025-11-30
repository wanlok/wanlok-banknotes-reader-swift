//
//  VuforiaDatasetViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 29/11/2025.
//

import UIKit

class VuforiaDatasetViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Sync",
            style: .plain,
            target: self,
            action: #selector(onSyncButtonClicked)
        )
        
        reload()
    }
    
    @objc private func onSyncButtonClicked() {
        downloadVuforiaDatabase() {
            self.reload()
        }
    }
    
    func downloadVuforiaDatabase(completion: @escaping () -> Void) {
        let group = DispatchGroup()
                
        func download(_ url: URL?, to: URL) {
            guard let url = url else {
                return
            }
            group.enter()
            URLSession.shared.downloadTask(with: url) { filePath, _, _ in
                if let filePath = filePath {
                    try? FileManager.default.removeItem(at: to)
                    try? FileManager.default.moveItem(at: filePath, to: to)
                }
                group.leave()
            }.resume()
        }
        
        let (xmlFilePath, datFilePath) = getVuforiaDatasetFilePaths()
        
        download(URL(string: "https://wanlok.github.io/\(vuforiaDatasetFileName).xml"), to: xmlFilePath)
        download(URL(string: "https://wanlok.github.io/\(vuforiaDatasetFileName).dat"), to: datFilePath)
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func reload() {
        let (filePath, _) = getVuforiaDatasetFilePaths()
        let values = getXMLAttributeValues(filePath: filePath, elementName: "ImageTarget", attributeNames: ["name", "size"])
        print(values)
    }
}
