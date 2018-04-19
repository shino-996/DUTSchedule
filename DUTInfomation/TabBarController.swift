//
//  TabBarController.swift
//  DUTInfomation
//
//  Created by shino on 14/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import UIKit
import DUTInfo
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
        guard let rootVC = viewControllers?.first as? TabViewController else {
            fatalError()
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let currentVC = selectedViewController as? TabViewController else {
            fatalError()
        }
        guard let nextVC = viewController as? TabViewController else {
            fatalError()
        }
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
        guard let password = KeyInfo.shared.getAccount() else {
            return
        }
        let keys = ["studentnumber": password.studentNumber,
                    "teachpassword": password.teachPassword,
                    "portalpassword": password.portalPassword]
        var courses: [[String: String]]?
        if let controller = selectedViewController as? ScheduleViewController {
            courses = controller.dataSource.data.courses
        } else {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.persistentContainer.viewContext
            courses = CourseInfo(context: context).coursesThisWeek().courses
        }
        let message = ["syncdata": ["keys": keys, "courses": courses as Any]]
        session.sendMessage(message, replyHandler: nil) { error in
            print(error)
        }
    }
}
