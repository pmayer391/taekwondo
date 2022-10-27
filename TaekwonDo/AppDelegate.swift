//
//  AppDelegate.swift
//  TaekwonDo
//
//  Created by Paul Mayer on 10/26/22.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let navController = NavController()
        let mainVC = MainVC(nibName: "MainVC", bundle: Bundle.main)
        navController.viewControllers = [mainVC]
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
        return true
    }
}

