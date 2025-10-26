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
        return [
            (title: "Settings", rows: [
                (title: "Detection Methods", subtitle: getDetectionMethods(), accessoryType: .disclosureIndicator),
//                (title: "B", subtitle: nil, accessoryType: nil),
//                (title: "C", subtitle: nil, accessoryType: nil)
            ]),
//            (title: "Settings", rows: [
//                (title: "A", subtitle: nil, accessoryType: nil),
//                (title: "B", subtitle: nil, accessoryType: nil)
//            ]),
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
    
    func getDetectionMethods() -> String? {
        guard let sceneDelegate = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive })?.delegate as? SceneDelegate else {
            return nil
        }
        let cameraViewController = sceneDelegate.getCameraViewController()
        return if cameraViewController is ARSCNViewController {
            "ARKit"
        } else {
            "Dummy"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.section) \(indexPath.row)")
        if indexPath.section == 0 && indexPath.row == 0 {
            navigationController?.pushViewController(DetectionMethodsViewController(), animated: true)
        }
    }
}
