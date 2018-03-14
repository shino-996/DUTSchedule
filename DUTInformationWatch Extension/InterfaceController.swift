//
//  InterfaceController.swift
//  DUTInformationWatch Extension
//
//  Created by shino on 08/03/2018.
//  Copyright © 2018 shino. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import DUTInfo

class InterfaceController: WKInterfaceController {
    @IBOutlet var informationTable: WKInterfaceTable!
    
    var courseData: [[String: String]]?
    let session = WCSession.default
    var dutInfo: DUTInfo!
    var courseInfo: CourseInfo!
    var cacheInfo: CacheInfo!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        userVerify()
    }
    
    func userVerify() {
        if let account = KeyInfo.getCurrentAccount() {
            initInfo(account: account)
        } else {
            informationTable.insertRows(at: [0], withRowType: "SyncRow")
        }
        session.delegate = self
        session.activate()
    }
    
    func initInfo(account: [String: String], courses: [[String: String]]? = nil) {
        if informationTable.numberOfRows != 0 {
            informationTable.removeRows(at: [0])
        }
        let studentNumber = account["number"]!
        let (teachPassword, portalPassword) = KeyInfo.loadPassword(studentNumber: studentNumber)
        dutInfo = DUTInfo(studentNumber: studentNumber,
                          teachPassword: teachPassword,
                          portalPassword: portalPassword)
        courseInfo = CourseInfo()
        cacheInfo = CacheInfo()
        cacheInfo.netCostHandle = { [weak self] cost in
            DispatchQueue.main.async {
                (self?.informationTable.rowController(at: 0) as? NetRow)?.prepare(flow: (self?.cacheInfo.netFlowText)!, cost: cost)
            }
        }
        cacheInfo.ecardCostHandle = { [weak self] ecard in
            DispatchQueue.main.async {
                (self?.informationTable.rowController(at: 1) as? EcardRow)?.prepare(ecard: ecard)
            }
        }
        if courseInfo.allCourseData == nil {
            courseInfo.allCourseData = courses
        }
        courseData = courseInfo.coursesToday().courses
        informationTable.insertRows(at: [0], withRowType: "NetRow")
        informationTable.insertRows(at: [1], withRowType: "EcardRow")
        loadInformation()        
        WKExtension.shared().delegate = self
        fetchInfoBackground(interval: Date())
    }
    
    func loadInformation() {
        cacheInfo.netCostHandle?(cacheInfo.netCostText)
        cacheInfo.ecardCostHandle?(cacheInfo.ecardText)
        for i in 2 ..< 2 + (courseData?.count ?? 0) {
            informationTable.insertRows(at: [i], withRowType: "CourseRow")
            let row = informationTable.rowController(at: i) as! CourseRow
            row.prepare(course: courseData![i - 2])
        }
    }
}

extension InterfaceController: WCSessionDelegate {
    func requestSync() {
        if dutInfo == nil {
        let message = ["message": "sync request"]
            session.sendMessage(message, replyHandler: nil) { error in
                print("Watch request error!")
                print(error)
            }
        }
    }
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        requestSync()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if dutInfo != nil {
            return
        }
        if (message["message"] as? String) == "sync request" {
            requestSync()
        }
        if let syncData = message["syncdata"] as? [String: Any] {
            let keys = syncData["keys"] as! [String: String]
            let studentNumber = keys["studentnumber"]!
            let teachPassword = keys["teachpassword"]!
            let portalPassword = keys["portalpassword"]!
            KeyInfo.savePassword(studentNumber: studentNumber,
                                 teachPassword: teachPassword,
                                 portalPassword: portalPassword)
            let account = ["name": "XXX", "number": studentNumber]
            let courses = syncData["courses"] as! [[String: String]]
            KeyInfo.updateAccounts(accounts: [account])
            initInfo(account: account, courses: courses)
        }
    }
}

extension InterfaceController: WKExtensionDelegate {
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            if let message = task.userInfo as? [String: String] {
                if message["tag"] == "fetchbackground" {
                    DispatchQueue.global().async {
                        let (cost, flow) = self.dutInfo.netInfo()
                        let ecard = self.dutInfo.moneyInfo()
                        self.cacheInfo.netCost = cost
                        self.cacheInfo.netFlow = flow
                        self.cacheInfo.ecardCost = ecard
                        let complicationServer = CLKComplicationServer.sharedInstance()
                        if let complications = complicationServer.activeComplications {
                            for complication in complications {
                                complicationServer.reloadTimeline(for: complication)
                            }
                        }
                    }
                }
            }
            if cacheInfo.netCost == 0 {
                fetchInfoBackground(interval: Date(timeIntervalSinceNow: 30))
            } else {
                fetchInfoBackground(interval: Date(timeIntervalSinceNow: 60 * 30))
            }
            task.setTaskCompletedWithSnapshot(true)
        }
    }
    
    func fetchInfoBackground(interval: Date = Date()) {
        let userInfo = ["tag": "fetchbackground"] as NSDictionary
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: interval, userInfo: userInfo) { error in
            if let error = error {
                print("watch fetch background error")
                print(error)
            }
        }
    }
}
