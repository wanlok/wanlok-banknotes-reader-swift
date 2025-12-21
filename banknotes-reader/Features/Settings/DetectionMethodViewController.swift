//
//  DetectionMethodViewController.swift
//  banknotes-reader
//
//  Created by wanlok on 20/12/2025.
//

import UIKit

class DetectionMethodViewController: SettingViewController {
    override var sections: [(title: String, rows: [SettingRow])] {
        return [
            (title: Localization.shared.get("detection_method_title"), rows: detectionMethods.enumerated().map { i, detectionMethod in
                TitleSubtitleAccessoryTypeRow(
                    title: detectionMethod.title,
                    subtitle: nil,
                    accessoryType: isRowSelected("detectionMethod", i)
                )
            })
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.shared.get("detection_method_title")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sceneDelegate = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive })?.delegate as? SceneDelegate else {
            return
        }
        sceneDelegate.changeCameraViewController(indexPath.row)
        defaults.set(indexPath.row, forKey: "detectionMethod")
        tableView.reloadData()
    }
}
