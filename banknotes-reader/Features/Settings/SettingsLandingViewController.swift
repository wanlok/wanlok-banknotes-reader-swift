//
//  SettingsLandingViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 26/10/2025.
//

import UIKit

typealias Row = (
    title: String,
    subtitle: String?,
    accessoryType: UITableViewCell.AccessoryType?
)

class SettingsLandingViewController: SettingsViewController {
    override var sections: [(
        title: String,
        rows: [Row]
    )] {
        return [
            (title: "Settings", rows: getSettingRows()),
            (title: "Languages", rows: getLanguageRows())
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func getDetectionMethod() -> String? {
        guard let sceneDelegate = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive })?.delegate as? SceneDelegate, let viewController = sceneDelegate.getCameraViewController() else {
            return nil
        }
        var title: String? = nil
        for detectionMethod in detectionMethods {
            if viewController.isKind(of: detectionMethod.type) {
                title = detectionMethod.title
                break
            }
        }
        return title
    }
    
    func getSettingRows() -> [Row] {
        var rows: [Row] = []
        let detectionMethod = getDetectionMethod()
        rows.append((title: "Detection Methods", subtitle: detectionMethod, accessoryType: .disclosureIndicator))
        if detectionMethod != "Dummy" {
            rows.append((title: "Dataset", subtitle: nil, accessoryType: .disclosureIndicator))
        }
        return rows
    }
    
    func getLanguageRows() -> [Row] {
        var rows: [Row] = []
        rows.append((title: "Languages", subtitle: "English", accessoryType: .disclosureIndicator))
        return rows
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            navigationController?.pushViewController(DetectionMethodsViewController(), animated: true)
        } else if indexPath.section == 0 && indexPath.row == 1 {
            if getDetectionMethod() == "Vuforia" {
                navigationController?.pushViewController(VuforiaDatasetViewController(), animated: true)
            } else {
                navigationController?.pushViewController(ARKitDatasetViewController(), animated: true)
            }
        }
    }
}
