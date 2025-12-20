//
//  LanguageViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 16/12/2025.
//

import UIKit
import AVFoundation

class LanguageViewController: SettingViewController {
    override var sections: [(title: String, rows: [SettingRow])] {
        return [
            (title: Localization.shared.get("language_title"), rows: languages.enumerated().map { i, language in
                (
                    title: language.title,
                    subtitle: nil,
                    accessoryType: isRowSelected("language", i)
                )
            })
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLanguage()
    }
    
    func updateLanguage() {
        Localization.shared.update()
        if let viewControllers = tabBarController?.viewControllers {
            let cameraViewController = viewControllers[0]
            cameraViewController.title = Localization.shared.get("camera_title")
        }
        if let viewControllers = navigationController?.viewControllers {
            let settingLandingViewController = viewControllers[viewControllers.count - 2]
            settingLandingViewController.title = Localization.shared.get("setting_landing_title")
        }
        title = Localization.shared.get("language_title")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defaults.set(indexPath.row, forKey: "language")
        defaults.removeObject(forKey: "voiceIdentifier")
        updateLanguage()
        tableView.reloadData()
    }
}
