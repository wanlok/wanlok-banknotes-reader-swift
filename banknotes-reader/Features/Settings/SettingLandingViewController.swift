//
//  SettingLandingViewController.swift
//  banknotes-reader
//
//  Created by wanlok on 20/12/2025.
//

import UIKit
import AVFoundation

class SettingLandingViewController: SettingViewController {
    override var sections: [(title: String, rows: [SettingRow])] {
        return [
            (title: Localization.shared.get("setting_landing_title"), rows: getSettingRows()),
            (title: Localization.shared.get("setting_landing_language"), rows: getLanguageRows())
        ]
    }
    
    func getSettingRows() -> [SettingRow] {
        var rows: [SettingRow] = []
        rows.append((title: Localization.shared.get("setting_landing_detection_method"), subtitle: detectionMethods[defaults.integer(forKey: "detectionMethod")].title, accessoryType: .disclosureIndicator))
        let index = defaults.integer(forKey: "detectionMethod")
        if index == 0 || index == 1 {
            rows.append((title: Localization.shared.get("setting_landing_dataset"), subtitle: nil, accessoryType: .disclosureIndicator))
        }
        return rows
    }
    
    func getLanguageRows() -> [SettingRow] {
        var rows: [SettingRow] = []
        let isVoiceOverRunning = UIAccessibility.isVoiceOverRunning
        rows.append((title: Localization.shared.get("setting_landing_language"), subtitle: languages[defaults.integer(forKey: "language")].title, accessoryType: .disclosureIndicator))
        rows.append((title: "VoiceOver", subtitle: isVoiceOverRunning ? Localization.shared.get("setting_landing_voice_over_on") : Localization.shared.get("setting_landing_voice_over_off"), accessoryType: nil))
        if !isVoiceOverRunning {
            rows.append((title: Localization.shared.get("setting_landing_voice"), subtitle: getSelectedVoice(defaults)?.name, accessoryType: .disclosureIndicator))
        }
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
            navigationController?.pushViewController(DetectionMethodViewController(), animated: true)
        } else if indexPath.section == 0 && indexPath.row == 1 { // Dataset
            let index = defaults.integer(forKey: "detectionMethod")
            if index == 0 {
                navigationController?.pushViewController(ARKitDatasetViewController(), animated: true)
            } else if index == 1 {
                navigationController?.pushViewController(VuforiaDatasetViewController(), animated: true)
            }
        } else if indexPath.section == 1 && indexPath.row == 0 {
            navigationController?.pushViewController(LanguageViewController(), animated: true)
        } else if indexPath.section == 1 && indexPath.row == 2 {
            navigationController?.pushViewController(VoiceViewController(), animated: true)
        } else {
            tableView.reloadData()
        }
    }
}
