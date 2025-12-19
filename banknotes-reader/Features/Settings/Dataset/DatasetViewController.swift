//
//  DatasetViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 30/11/2025.
//

import UIKit

struct Banknote: Codable {
    let name: String
    let url: String?
    let width: Double
    let height: Double
}

struct DatasetRow {
    let key: String?
    let banknote: Banknote
    let imageData: Data?
}

class DatasetViewController: NetworkViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let identifier: String = "DatasetViewController"
    
    var sections: [(title: String, rows: [DatasetRow])] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.shared.get("dataset_title")
        
        activityIndicator.startAnimating()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "DatasetTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: Localization.shared.get("dataset_sync"),
            style: .plain,
            target: self,
            action: #selector(onSyncButtonClicked)
        )
    }
    
    @objc func onSyncButtonClicked() {
        
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
        let row = sections[indexPath.section].rows[indexPath.row]
        let banknote = row.banknote
        if let imageData = row.imageData {
            cell.previewImageView.image = UIImage(data: imageData)
        }
        cell.nameLabel.text = banknote.name
        cell.widthLabel.text = "\(banknote.width)"
        cell.heightLabel.text = "\(banknote.height)"
        return cell
    }
}
