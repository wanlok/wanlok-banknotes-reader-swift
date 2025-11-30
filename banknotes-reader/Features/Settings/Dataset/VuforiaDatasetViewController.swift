//
//  VuforiaDatasetViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 29/11/2025.
//

import UIKit

struct VuforiaBanknote: Codable {
    let name: String
    let width: Double
    let height: Double
}

class VuforiaDatasetViewController: NetworkViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let identifier: String = "VuforiaDatasetViewController"
    
    var sections: [(title: String, rows: [VuforiaBanknote])] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dataset"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Sync",
            style: .plain,
            target: self,
            action: #selector(onSyncButtonClicked)
        )
        
        activityIndicator.startAnimating()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "DatasetTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
        
        reload()
    }
    
    @objc private func onSyncButtonClicked() {
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
        var rows: [VuforiaBanknote] = []
        for i in 0..<names.count {
            let slices = sizes[i].split(separator: " ")
            if slices.count >= 2 {
                let width = Double(slices[0])
                let height = Double(slices[1])
                if let width = width, let height = height {
                    rows.append(VuforiaBanknote(name: names[i], width: width, height: height))
                }
            }
        }
        sections = [(title: "Dataset", rows: rows)]
        tableView.reloadData()
        activityIndicator.isHidden = true
        tableView.isHidden = false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? DatasetTableViewCell else {
            fatalError("tableView cellForRowAt")
        }
        let banknote = sections[indexPath.section].rows[indexPath.row]
//        cell.previewImageView.image = UIImage(data: imageData)
        cell.nameLabel.text = banknote.name
        cell.widthLabel.text = "\(banknote.width)"
        cell.heightLabel.text = "\(banknote.height)"
        return cell
    }
}
