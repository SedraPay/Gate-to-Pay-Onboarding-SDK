//
//  AppDelegate.swift
//  Example
//
//  Created by Amani on 04/12/2025.
//

import UIKit
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        //DocumentsCameraViewController
        
        //NFX.sharedInstance().start()
        
        IQKeyboardManager.shared.isEnabled = true
        
        
        
        
        return true
    }

    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        guard let rootViewController = self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController),
         (rootViewController.responds(to: Selector(("canRotate")))) else{
            // Only allow portrait (standard behaviour)
            return .portrait;
        }
        // Unlock landscape view orientations for this view controller
        return .landscapeRight;
    }

    private func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
        guard rootViewController != nil else { return nil }

        guard !(rootViewController.isKind(of: (UITabBarController).self)) else{
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UITabBarController).selectedViewController)
        }
        guard !(rootViewController.isKind(of:(UINavigationController).self)) else{
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
        }
        guard !(rootViewController.presentedViewController != nil) else{
            return topViewControllerWithRootViewController(rootViewController: rootViewController.presentedViewController)
        }
        return rootViewController
    }
}

