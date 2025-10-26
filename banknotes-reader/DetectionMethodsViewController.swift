//
//  DetectionMethodsViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 26/10/2025.
//

import UIKit

class DetectionMethodsViewController: SettingsViewController {
    override var sections: [(title: String, rows: [String])] {
        return [
            (title: "Libraries", rows: ["ARKit", "B"])
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
    }
}
