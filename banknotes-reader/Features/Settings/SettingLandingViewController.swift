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
        rows.append(TitleSubtitleAccessoryTypeRow(title: Localization.shared.get("setting_landing_detection_method"), subtitle: detectionMethods[defaults.integer(forKey: "detectionMethod")].title, accessoryType: .disclosureIndicator))
        let index = defaults.integer(forKey: "detectionMethod")
        if index == 0 || index == 1 {
            rows.append(TitleSubtitleAccessoryTypeRow(title: Localization.shared.get("setting_landing_dataset"), subtitle: nil, accessoryType: .disclosureIndicator))
        }
        return rows
    }
    
    func getLanguageRows() -> [SettingRow] {
        var rows: [SettingRow] = []
        let isVoiceOverRunning = UIAccessibility.isVoiceOverRunning
        let rate: Float
        if defaults.object(forKey: "rate") == nil {
            rate = AVSpeechUtteranceDefaultSpeechRate
        } else {
            rate = defaults.float(forKey: "rate")
        }
        let pitch: Float
        if defaults.object(forKey: "pitch") == nil {
            pitch = 1.0
        } else {
            pitch = defaults.float(forKey: "pitch")
        }
        rows.append(TitleSubtitleAccessoryTypeRow(title: Localization.shared.get("setting_landing_language"), subtitle: languages[defaults.integer(forKey: "language")].title, accessoryType: .disclosureIndicator))
        rows.append(TitleSubtitleAccessoryTypeRow(title: "VoiceOver", subtitle: isVoiceOverRunning ? Localization.shared.get("setting_landing_voice_over_on") : Localization.shared.get("setting_landing_voice_over_off"), accessoryType: nil))
        if !isVoiceOverRunning {
            rows.append(TitleSubtitleAccessoryTypeRow(title: Localization.shared.get("setting_landing_voice"), subtitle: getSelectedVoice(defaults)?.name, accessoryType: .disclosureIndicator))
            rows.append(TitleSliderRow(title: Localization.shared.get("setting_landing_rate"), min: AVSpeechUtteranceMinimumSpeechRate, max: AVSpeechUtteranceMaximumSpeechRate, value: rate))
            rows.append(TitleSliderRow(title: Localization.shared.get("setting_landing_pitch"), min: 0.5, max: 2.0, value: pitch))
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
    
    override func tableViewCellSliderEnded(_ indexPath: IndexPath, _ value: Float) {
        if indexPath.section == 1 && indexPath.row == 3 {
            defaults.setValue(value, forKey: "rate")
        } else if indexPath.section == 1 && indexPath.row == 4 {
            defaults.setValue(value, forKey: "pitch")
        }
    }
}
