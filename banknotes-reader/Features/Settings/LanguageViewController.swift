//
//  LanguageViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 16/12/2025.
//

import UIKit

class LanguageViewController: SettingViewController {
    override var sections: [(title: String, rows: [SettingRow])] {
        let rows: [SettingRow] = [
            (title: "English", subtitle: nil, accessoryType: .checkmark),
            (title: "繁體中文", subtitle: nil, accessoryType: nil)
        ]
        return [
            (title: "Languages", rows: rows)
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Languages"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}
