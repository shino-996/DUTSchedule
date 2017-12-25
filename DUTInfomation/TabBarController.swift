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
        let dutInfo = DUTInfo()
        if let studentNumber = KeyInfo.getCurrentAccount() {
            let (teachPassword, portalPassword) = KeyInfo.loadPassword(studentNumber: studentNumber)
            dutInfo.studentNumber = studentNumber
            dutInfo.teachPassword = teachPassword
            dutInfo.portalPassword = portalPassword
        }
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
