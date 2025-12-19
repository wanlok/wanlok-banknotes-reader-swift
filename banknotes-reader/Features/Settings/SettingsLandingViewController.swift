//
//  SettingsLandingViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 26/10/2025.
//

import UIKit

class SettingsLandingViewController: SettingViewController {
    override var sections: [(title: String, rows: [SettingRow])] {
        return [
            (title: Localization.shared.get("setting_landing_title"), rows: getSettingRows()),
            (title: Localization.shared.get("setting_landing_languages"), rows: getLanguageRows())
        ]
    }
    
    func getSettingRows() -> [SettingRow] {
        var rows: [SettingRow] = []
        let detectionMethod = detectionMethods[defaults.integer(forKey: "detectionMethod")].title
        rows.append((title: Localization.shared.get("setting_landing_detection_method"), subtitle: detectionMethod, accessoryType: .disclosureIndicator))
        let index = defaults.integer(forKey: "detectionMethod")
        if index == 0 || index == 1 {
            rows.append((title: Localization.shared.get("setting_landing_dataset"), subtitle: nil, accessoryType: .disclosureIndicator))
        }
        return rows
    }
    
    func getLanguageRows() -> [SettingRow] {
        var rows: [SettingRow] = []
        let language = languages[defaults.integer(forKey: "language")].title
        rows.append((title: Localization.shared.get("setting_landing_languages"), subtitle: language, accessoryType: .disclosureIndicator))
        return rows
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Localization.shared.update()
        title = Localization.shared.get("setting_landing_title")
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            navigationController?.pushViewController(DetectionMethodsViewController(), animated: true)
        } else if indexPath.section == 0 && indexPath.row == 1 { // Dataset
            let index = defaults.integer(forKey: "detectionMethod")
            if index == 0 {
                navigationController?.pushViewController(ARKitDatasetViewController(), animated: true)
            } else if index == 1 {
                navigationController?.pushViewController(VuforiaDatasetViewController(), animated: true)
            }
        } else if indexPath.section == 1 && indexPath.row == 0 {
            navigationController?.pushViewController(LanguageViewController(), animated: true)
        }
    }
}
