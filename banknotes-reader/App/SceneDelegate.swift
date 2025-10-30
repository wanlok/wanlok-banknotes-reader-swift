//
//  SceneDelegate.swift
//  banknotes-reader
//
//  Created by Robert Wan on 21/10/2025.
//
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var tabBarController: UITabBarController?
    
    func getCameraViewController() -> UIViewController? {
        return tabBarController?.viewControllers?[0]
    }

    func changeCameraViewController(_ i: Int) {
        var cameraViewController: UIViewController;
        if i == 0 {
            cameraViewController = ARSCNViewController()
        } else {
            cameraViewController = DummyViewController()
        }
        cameraViewController.tabBarItem = UITabBarItem(title: "Camera", image: UIImage(systemName: "camera"), tag: 0)
        var viewControllers = tabBarController?.viewControllers ?? []
        if viewControllers.count > 0 {
            viewControllers[0] = cameraViewController
        } else {
            viewControllers = [
                cameraViewController
            ]
        }
        tabBarController?.viewControllers = viewControllers
    }
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        tabBarController = UITabBarController()
        
        changeCameraViewController(0)
        
        let settingsViewController = SettingsLandingViewController()
        settingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 1)
        tabBarController?.viewControllers?.append(UINavigationController(rootViewController: settingsViewController))
        
        // Set up window
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }
}
