//
//  SceneDelegate.swift
//  AlchemyUIKit
//
//  Created by Arseniy Zolotarev on 10.09.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let playingAreaVC = PlayingAreaViewController()
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UINavigationController(rootViewController: playingAreaVC)
        window?.overrideUserInterfaceStyle = .light
        window?.makeKeyAndVisible()
    }
}
