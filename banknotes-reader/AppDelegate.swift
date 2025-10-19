//
//  AppDelegate.swift
//  banknotes-reader
//
//  Created by Robert Wan on 19/10/2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController(rootViewController: LandingViewController())
        self.window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
}

