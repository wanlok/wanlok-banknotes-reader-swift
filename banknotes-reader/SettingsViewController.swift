//
//  SettingsViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 19/10/2025.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let settings: [(title: String, items: [String])] = [
        (title: "Settings", items: ["A", "B", "C"]),
        (title: "Voice", items: ["A", "B"]),
        (title: "About", items: ["A", "B"])
    ]
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        settingsTableView.dataSource = self
        settingsTableView.delegate = self
        settingsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsTableViewCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath)
        let item = settings[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settings[section].title
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      return section == 0 ? 40 : 24
    }
}
