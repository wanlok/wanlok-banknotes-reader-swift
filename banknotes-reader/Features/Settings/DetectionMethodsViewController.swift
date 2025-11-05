//
//  DetectionMethodsViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 26/10/2025.
//

import UIKit

class DetectionMethodsViewController: SettingsViewController {
    override var sections:  [(
        title: String,
        rows: [(title: String, subtitle: String?, accessoryType: UITableViewCell.AccessoryType?)]
    )] {
        let rows: [(title: String, subtitle: String?, accessoryType: UITableViewCell.AccessoryType?)] = detectionMethods.map { detectionMethod in
            (
                title: detectionMethod.title,
                subtitle: nil,
                accessoryType: getDetectionMethodAccessoryType(detectionMethod.title)
            )
        }
        return [
            (title: "Detection Methods", rows: rows)
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detection Methods"
    }
    
    func getDetectionMethodAccessoryType(_ title: String) -> UITableViewCell.AccessoryType? {
        guard let sceneDelegate = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive })?.delegate as? SceneDelegate, let viewController = sceneDelegate.getCameraViewController() else {
            return nil
        }
        var accessoryType: UITableViewCell.AccessoryType? = nil
        for detectionMethod in detectionMethods {
            if detectionMethod.title == title && viewController.isKind(of: detectionMethod.type) {
                accessoryType = .checkmark
                break
            }
        }
        return accessoryType
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sceneDelegate = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive })?.delegate as? SceneDelegate else {
            return
        }
        sceneDelegate.changeCameraViewController(indexPath.row)
        tableView.reloadData()
    }
}
