//
//  showEmptyDatasetAlert.swift
//  banknotes-reader
//
//  Created by wanlok on 4/1/2026.
//

import UIKit

func showEmptyDatasetAlert(_ viewController: UIViewController, _ defaults: UserDefaults) {
    DispatchQueue.main.async {
        let alertController = UIAlertController(title: "Empty Dataset", message: "The app will navigate to the dataset page. Please sync the dataset.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            guard let tabBarController = viewController.tabBarController, let navigationController = tabBarController.viewControllers?[1] as? UINavigationController else {
                return
            }
            navigationController.popToRootViewController(animated: false)
            navigateDatasetViewController(navigationController, defaults)
            tabBarController.selectedIndex = 1
        })
        viewController.present(alertController, animated: true, completion: nil)
    }
}
