//
//  AppDelegate.swift
//  BilanCO2
//
//  Created by Jérôme Kasparian on 04/09/2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?  // pour le support iOS 12 : voir https://stackoverflow.com/questions/58405393/appdelegate-and-scenedelegate-when-supporting-ios-12-and-13


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        if #available(iOS 13.0, *) {
//            window?.overrideUserInterfaceStyle = .light
//        }
#if targetEnvironment(macCatalyst) //modifié
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
                windowScene.sizeRestrictions?.minimumSize = CGSize(width: 320, height: 480)
            }
        }
#else
        if estiOSAppSurMac() {
            if #available(iOS 13.0, *) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { 
                    UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
                        windowScene.sizeRestrictions?.minimumSize = CGSize(width: 320, height: 480)
                    }
                }
            }
        }
#endif
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func estiOSAppSurMac() -> Bool { // https://developer.apple.com/forums/thread/656122
        //            path to the "Documents" folder on iOS:
        //              "/var/mobile/Containers/Data/Application/8C2D631A-DCBB-44FE-8F86-429A89FCE921/Documents" -> iOS
        //            path to the "Documents" folder on macOS:
        //              "/Users/USER_NAME/Library/Containers/4EE76C41-2BE8-4A65-B26C-080773E0EB31/Data/Documents"  -> Mac
        if #available(iOS 14.0, *) {
            return ProcessInfo.processInfo.isiOSAppOnMac
        } else if #available(iOS 9.0, *){  // cette méthode marcherait aussi sous iOS 14/15 mais pourrait ne plus marcher à l'avenir si Apple change le chemin par défaut du dossiers documents
            let prefixeDocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path.components(separatedBy: "/")[1]
//            print("Prefixe Document Directory : ", prefixeDocumentsDirectory)
            return prefixeDocumentsDirectory == "Users"
        } else {  // Catalyst
            return false
        }
    }

    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

