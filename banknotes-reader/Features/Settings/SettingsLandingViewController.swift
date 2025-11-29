//
//  SettingsLandingViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 26/10/2025.
//

import UIKit

class SettingsLandingViewController: SettingsViewController {
    override var sections: [(
        title: String,
        rows: [(title: String, subtitle: String?, accessoryType: UITableViewCell.AccessoryType?)]
    )] {
        let detectionMethod = getDetectionMethod()
        var rows: [(title: String, subtitle: String?, accessoryType: UITableViewCell.AccessoryType?)] = [
            (title: "Detection Methods", subtitle: detectionMethod, accessoryType: .disclosureIndicator),
        ]
        if detectionMethod != "Dummy" {
            rows.append((title: "Dataset", subtitle: nil, accessoryType: .disclosureIndicator))
        }
        return [
            (title: "Settings", rows: rows),
//            (title: "About", rows:  [
//                (title: "A", subtitle: nil, accessoryType: nil),
//                (title: "B", subtitle: nil, accessoryType: nil)
//            ])
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            navigationController?.pushViewController(DetectionMethodsViewController(), animated: true)
        } else if indexPath.section == 0 && indexPath.row == 1 {
            if getDetectionMethod() == "Vuforia" {
                navigationController?.pushViewController(VuforiaDatasetViewController(), animated: true)
            } else {
                navigationController?.pushViewController(DatasetViewController(), animated: true)
            }
        }
    }
}
