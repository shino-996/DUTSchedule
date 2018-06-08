//
//  TabBarController.swift
//  DUTInfomation
//
//  Created by shino on 14/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import UIKit
import WatchConnectivity
import CoreData

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    private let session = WCSession.default
    let dataManager = DataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
        guard let currentVC = viewControllers?.first as? TabViewController else {
            fatalError("TabBarViewController type error")
        }
        currentVC.dataManager = dataManager
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let nextVC = viewController as? TabViewController else {
            fatalError("TabBarViewController type error")
        }
        guard let currentVC = selectedViewController as? TabViewController else {
            fatalError("TabBatViewController type error")
        }
        nextVC.dataManager = currentVC.dataManager
        return true
    }
}

extension TabBarController: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        let message = ["message": "sync request"]
        session.sendMessage(message, replyHandler: nil) { error in
            print("iPhone sync error")
            print(error)
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard (message["message"] as? String) == "sync request" else {
            return
        }
        guard let password = UserInfo.shared.getAccount() else {
            return
        }
        let keys = ["studentnumber": password.studentNumber,
                    "password": password.password]
        let url = dataManager.backupFile()
        do {
            let data = try Data(contentsOf: url)
            let message = ["syncdata": ["keys": keys, "data": data]]
            session.sendMessage(message, replyHandler: nil) { error in
                print(error)
            }
            defer {
                try! FileManager.default.removeItem(at: url)
            }
        } catch(let error) {
            print(error)
            fatalError()
        }
    }
}
