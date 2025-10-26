//
//  SceneDelegate.swift
//  banknotes-reader
//
//  Created by Robert Wan on 21/10/2025.
//
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let arscnViewController = ARSCNViewController()
        arscnViewController.tabBarItem = UITabBarItem(title: "Camera", image: UIImage(systemName: "camera"), tag: 0)

        let settingsViewController = SettingsLandingViewController(sections: Settings.landing)
        settingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 1)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            arscnViewController,
            UINavigationController(rootViewController: settingsViewController)
        ]

        // Apply Liquid Glass style (iOS 26+)
        if #available(iOS 26.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            tabBarController.tabBar.standardAppearance = appearance
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }

        // Set up window
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }
}
