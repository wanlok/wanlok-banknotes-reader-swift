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
    let defaults = UserDefaults.standard
    
    func getCameraViewController() -> UIViewController? {
        return tabBarController?.viewControllers?[0]
    }

    func changeCameraViewController(_ i: Int) {
        let cameraViewController = detectionMethods[i].type.init()
        cameraViewController.tabBarItem = UITabBarItem(title: "Camera", image: UIImage(systemName: "camera"), tag: 0)
        var viewControllers = tabBarController?.viewControllers ?? []
        if viewControllers.count > 0 {
            viewControllers[0] = cameraViewController
        } else {
            viewControllers = [cameraViewController]
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
        
        changeCameraViewController(defaults.integer(forKey: "detectionMethod"))
        
        let settingViewController = SettingsLandingViewController()
        settingViewController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 1)
        tabBarController?.viewControllers?.append(UINavigationController(rootViewController: settingViewController))
        
        // Set up window
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }
}
