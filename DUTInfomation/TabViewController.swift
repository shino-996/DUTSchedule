//
//  TabViewController.swift
//  DUTInfomation
//
//  Created by shino on 14/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import UIKit
import DUTInfo
import WatchConnectivity

//所有tab页面的基类, 便于进行账号信息的依赖注入
class TabViewController: UIViewController, WCSessionDelegate {
    var dutInfo: DUTInfo!
    var loginHandler: (() -> Void)?
    let session = WCSession.default
    
    func performLogin() {
        performSegue(withIdentifier: "LoginTeach", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginTeach" {
            let navigation = segue.destination as! UINavigationController
            let destination = navigation.topViewController as! LoginTeachSiteViewController
            destination.dutInfo = dutInfo
            destination.loginHandler = loginHandler
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    func syncData() {
        var message: [[String: String]]
        if let controller = self as? ScheduleViewController {
            message = controller.courseInfo.allCourseData ?? [[String: String]]()
        } else {
            let courseInfo = CourseInfo()
            message = courseInfo.allCourseData ?? [[String: String]]()
        }
        session.sendMessage(["course": message], replyHandler: nil, errorHandler: { error in
            print("Phone sync error!")
            print(error)
        })
    }
    
    @available(iOS 9.3, *)
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if activationState != .activated {
            if let error = error {
                print(error)
            }
        }
        syncData()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if message["message"] as? String ?? "" == "Sync request" {
            syncData()
        }
    }
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
}
