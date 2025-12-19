//
//  DetectionMethodsViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 26/10/2025.
//

import UIKit

class DetectionMethodsViewController: SettingViewController {
    override var sections: [(title: String, rows: [SettingRow])] {
        return [
            (title: "Detection Methods", rows: detectionMethods.enumerated().map { index, detectionMethod in
                (
                    title: detectionMethod.title,
                    subtitle: nil,
                    accessoryType: isRowSelected("detectionMethod", index)
                )
            })
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detection Methods"
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
