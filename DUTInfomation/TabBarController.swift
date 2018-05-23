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
    let session = WCSession.default
    var isLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        isLogin = KeyInfo.shared.getAccount() != nil
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
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
        guard let password = KeyInfo.shared.getAccount() else {
            return
        }
        let keys = ["studentnumber": password.studentNumber,
                    "password": password.password]
        var courses: [JSON]
        if let controller = selectedViewController as? ScheduleViewController {
            courses = controller.courseManager.exportJsonArray()
        } else {
            courses = CourseManager().exportJsonArray()
        }
        
        let message = ["syncdata": ["keys": keys, "courses": courses]]
        session.sendMessage(message, replyHandler: nil) { error in
            print(error)
        }
    }
}
