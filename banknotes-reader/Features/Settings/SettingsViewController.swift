//
//  SettingsViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 26/10/2025.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let identifier: String = "SettingsViewController"
    
    var sections:  [(
        title: String,
        rows: [(title: String, subtitle: String?, accessoryType: UITableViewCell.AccessoryType?)]
    )] {
        fatalError("Subclasses must override `sections`")
    }
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       if let tableView = view.subviews.compactMap({ $0 as? UITableView }).first,
          let indexPath = tableView.indexPathForSelectedRow {
           tableView.deselectRow(at: indexPath, animated: true)
       }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].title == title ? 0 : 24
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
        }
        guard let cell else {
            fatalError("tableView cellForRowAt")
        }
        let row = sections[indexPath.section].rows[indexPath.row]
        cell.textLabel?.text = row.title
        cell.detailTextLabel?.text = row.subtitle
        if let accessoryType = row.accessoryType {
            cell.accessoryType = accessoryType
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}
