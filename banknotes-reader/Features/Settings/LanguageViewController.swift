//
//  LanguageViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 16/12/2025.
//

import UIKit

class LanguageViewController: SettingViewController {
    override var sections: [(title: String, rows: [SettingRow])] {
        return [
            (title: "Languages", rows: languages.enumerated().map { index, language in
                (
                    title: language.title,
                    subtitle: nil,
                    accessoryType: isRowSelected("language", index)
                )
            })
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Languages"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defaults.set(indexPath.row, forKey: "language")
        print(indexPath.row)
        tableView.reloadData()
    }
}
