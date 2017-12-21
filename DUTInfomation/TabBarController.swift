//
//  TabBarController.swift
//  DUTInfomation
//
//  Created by shino on 14/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        let dutInfo = DUTInfo(studentNumber: userDefaults.string(forKey: "StudentNumber") ?? "",
                              teachPassword: userDefaults.string(forKey: "TeachPassword") ?? "",
                              portalPassword: userDefaults.string(forKey: "PortalPassword") ?? "")
        let controller = viewControllers?.first as! TabViewController
        controller.dutInfo = dutInfo
        controller.dutInfo.delegate = controller
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let nextViewController = viewController as! TabViewController
        let currentViewController = selectedViewController as! TabViewController
        nextViewController.dutInfo = currentViewController.dutInfo
        nextViewController.dutInfo.delegate = nextViewController
        return true
    }
}
