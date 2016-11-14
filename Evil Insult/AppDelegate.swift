//
//  AppDelegate.swift
//  Evil Insult
//
//  Created by Dmitri Kalinaitsev on 26/10/16.
//  Copyright © 2016 Dmitri Kalinaitsev. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCrash

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Initiate Firebase
        FIRApp.configure()
        
        // Show corresponding storyboard based on iOS device screen resolution
        let mainStoryboard = grabStoryboard()
        window?.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController")
        window?.makeKeyAndVisible()

        return true
    }
    
    // MARK: Functions
    func grabStoryboard() -> UIStoryboard {
        
        let screenHeight: CGFloat = UIScreen.main.bounds.size.height
        var storyboard: UIStoryboard
        
        switch screenHeight {
        case 1366:
            // 12.9-inch iPad Pro
            storyboard = UIStoryboard(name: "1024x1366", bundle: nil)
            UserDefaults.standard.set("1024x1366", forKey: Constants.kDeviceScreen)
        case 667:
            // iPhone 6, iPhone 6s, iPhone 7
            storyboard = UIStoryboard(name: "375x667", bundle: nil)
            UserDefaults.standard.set("375x667", forKey: Constants.kDeviceScreen)
        case 736:
            // iPhone 6 Plus, iPhone 6s Plus, iPhone 7 Plus
            storyboard = UIStoryboard(name: "414x736", bundle: nil)
            UserDefaults.standard.set("414x736", forKey: Constants.kDeviceScreen)
        case 1024:
            // iPad Mini 2, iPad Mini 3, iPad Mini 4, iPad 3, iPad 4, iPad Air, iPad Air 2, 9.7-inch iPad Pro
            storyboard = UIStoryboard(name: "768x1024", bundle: nil)
            UserDefaults.standard.set("768x1024", forKey: Constants.kDeviceScreen)
        case 568:
            // iPhone 5, 5C, 5S, iPod Touch 5g
            storyboard = UIStoryboard(name: "320x568", bundle: nil)
            UserDefaults.standard.set("320x568", forKey: Constants.kDeviceScreen)
        default:
            // iPhone 5, 5C, 5S, iPod Touch 5g
            storyboard = UIStoryboard(name: "320x568", bundle: nil)
            UserDefaults.standard.set("320x568", forKey: Constants.kDeviceScreen)
        }
        
        UserDefaults.standard.synchronize()
        
        return storyboard
    }

    // MARK: Delegates
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

