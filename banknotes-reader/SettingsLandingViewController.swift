//
//  SettingsLandingViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 26/10/2025.
//

import UIKit

class SettingsLandingViewController: SettingsViewController {
    override var sections: [(title: String, items: [String])] {
        return [
            (title: "Settings", items: ["Detection Methods", "B", "C"]),
            (title: "Voice", items: ["A", "B"]),
            (title: "About", items: ["A", "B"])
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.section) \(indexPath.row)")
        if indexPath.section == 0 && indexPath.row == 0 {
            navigationController?.pushViewController(DetectionMethodsViewController(), animated: true)
        }
    }
}
