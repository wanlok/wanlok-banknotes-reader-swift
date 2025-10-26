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
        return [
            (title: "Detection Methods", rows: [
                (title: "ARKit", subtitle: nil, accessoryType: getDetectionMethodAccessoryType("ARKit")),
                (title: "Dummy", subtitle: nil, accessoryType: getDetectionMethodAccessoryType("Dummy")),
            ])
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detection Methods"
    }
    
    func getDetectionMethodAccessoryType(_ title: String) -> UITableViewCell.AccessoryType? {
        guard let sceneDelegate = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive })?.delegate as? SceneDelegate else {
            return nil
        }
        let cameraViewController = sceneDelegate.getCameraViewController()
        return if title == "ARKit" && cameraViewController is ARSCNViewController {
            .checkmark
        } else if title == "Dummy" && cameraViewController is DummyViewController {
            .checkmark
        } else {
            nil
        }
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
