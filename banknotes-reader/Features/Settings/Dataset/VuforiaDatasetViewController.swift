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

class VuforiaDatasetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
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
        var rows: [VuforiaBanknote] = []
        for i in 0...values.count {
            guard let name = values["name"]?[i], let size = values["size"]?[i] else {
                continue
            }
            let slices = size.split(separator: " ")
            if slices.count >= 2 {
                let width = Double(slices[0])
                let height = Double(slices[1])
                if let width = width, let height = height {
                    rows.append(VuforiaBanknote(name: name, width: width, height: height))
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
