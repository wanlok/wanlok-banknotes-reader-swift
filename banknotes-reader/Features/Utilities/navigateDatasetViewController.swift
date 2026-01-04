//
//  navigateDatasetViewController.swift
//  banknotes-reader
//
//  Created by wanlok on 4/1/2026.
//

func navigateDatasetViewController(_ navigationController: UINavigationController?, _ defaults: UserDefaults) {
    let index = defaults.integer(forKey: "detectionMethod")
    if index == 0 {
        navigationController?.pushViewController(ARKitDatasetViewController(), animated: true)
    } else if index == 1 {
        navigationController?.pushViewController(VuforiaDatasetViewController(), animated: true)
    }
}
