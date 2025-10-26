//
//  SettingsViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 26/10/2025.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let identifier: String = "SettingsViewController"
    
    var sections: [(title: String, rows: [String])] {
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
        return section == 0 ? 40 : 24
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
        }
        guard let cell else {
            fatalError("tableView cellForRowAt")
        }
        cell.textLabel?.text = sections[indexPath.section].rows[indexPath.row]
        cell.detailTextLabel?.text = "Dummy"
        cell.accessoryType = .disclosureIndicator
//        cell.accessoryType = .checkmark
        return cell
    }
}
