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

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    let session = WCSession.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        let dutInfo = DUTInfo(studentNumber: "", teachPassword: "", portalPassword: "")
        if let studentNumber = KeyInfo.getCurrentAccount()?["number"] {
            let (teachPassword, portalPassword) = KeyInfo.loadPassword(studentNumber: studentNumber)
            dutInfo.studentNumber = studentNumber
            dutInfo.teachPassword = teachPassword
            dutInfo.portalPassword = portalPassword
        }
        let controller = viewControllers?.first as! TabViewController
        controller.dutInfo = dutInfo
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        let nextViewController = viewController as! TabViewController
        let currentViewController = selectedViewController as! TabViewController
        nextViewController.dutInfo = currentViewController.dutInfo
        return true
    }
}

extension TabBarController: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    
    @available(iOS 9.3, *)
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
        if let controller = selectedViewController as? ScheduleViewController {
            let keys = ["studentnumber": controller.dutInfo.studentNumber,
                        "teachpassword": controller.dutInfo.teachPassword,
                        "portalpassword": controller.dutInfo.portalPassword]
            let courses = controller.courseInfo.allCourseData
            let message = ["syncdata": ["keys": keys, "courses": courses as Any]]
            session.sendMessage(message, replyHandler: nil) { error in
                print(error)
            }
        }
        if let controller = selectedViewController as? CostViewController {
            let keys = ["studentnumber": controller.dutInfo.studentNumber,
                        "teachpassword": controller.dutInfo.teachPassword,
                        "portalpassword": controller.dutInfo.portalPassword]

            let courses = CourseInfo().allCourseData
            let message = ["syncdata": ["keys": keys, "courses": courses as Any]]
            session.sendMessage(message, replyHandler: nil) { error in
                print(error)
            }
        }
    }
}
