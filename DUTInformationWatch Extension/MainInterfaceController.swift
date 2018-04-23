//
//  MainInterfaceController.swift
//  DUTInformationWatch Extension
//
//  Created by shino on 08/03/2018.
//  Copyright © 2018 shino. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import DUTInfo
import CoreData

class MainInterfaceController: WKInterfaceController {
    @IBOutlet var informationTable: WKInterfaceTable!
    @IBOutlet var updateLabel: WKInterfaceLabel!
    
    var courseData: [TimeData]?
    let session = WCSession.default
    var courseManager: CourseManager!
    var cacheInfo: CacheInfo!
    var isSync = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if KeyInfo.shared.getAccount() != nil {
            infoInit()
        } else {
            let rowTypes = ["SyncRow"]
            informationTable.setRowTypes(rowTypes)
            session.delegate = self
            session.activate()
        }
    }
    
    func infoInit(_ courses: [[String: Any]]? = nil) {
        cacheInfo = CacheInfo()
        courseManager = CourseManager()
        if let courses = courses {
            courseManager.importData(dics: courses)
        }
        WKExtension.shared().delegate = self
        fetchInfoBackground(interval: Date())
        infoRefresh()
    }
    
    func infoRefresh() {
        var rowTypes = ["NetRow", "EcardRow"]
        courseData = courseManager.coursesToday().courses
        let courseNum = courseData?.count ?? 0
        for _ in 0 ..< courseNum {
            rowTypes += ["CourseRow"]
        }
        rowTypes += ["MoreCourseRow"]
        informationTable.setRowTypes(rowTypes)
        (informationTable.rowController(at: 0) as! NetRow).prepare(cacheInfo.netInfo)
        (informationTable.rowController(at: 1) as! EcardRow).prepare(cacheInfo.ecard)
        for i in 2 ..< 2 + courseNum {
            (informationTable.rowController(at: i) as! CourseRow).prepare(course: courseData![i - 2])
        }
        let complicationServer = CLKComplicationServer.sharedInstance()
        if let complications = complicationServer.activeComplications {
            for complication in complications {
                complicationServer.reloadTimeline(for: complication)
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm"
        updateLabel.setText("更新时间:" + dateFormatter.string(from: Date()))
    }
}

extension MainInterfaceController: WCSessionDelegate {
    func requestSync() {
        if isSync {
            return
        }
        let message = ["message": "sync request"]
            session.sendMessage(message, replyHandler: nil) { error in
                print("Watch request error!")
                print(error)
            }
    }
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        requestSync()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if isSync {
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
            KeyInfo.shared.setAccount((studentNumber, teachPassword, portalPassword))
            let courses = syncData["courses"] as! [[String: Any]]
            isSync = true
            infoInit(courses)
        }
    }
}

extension MainInterfaceController: WKExtensionDelegate {
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            if let message = task.userInfo as? [String: String] {
                if message["tag"] == "fetchbackground" {
                    cacheInfo.loadCacheAsync() {
                        self.infoRefresh()
                    }
                }
            }
            fetchInfoBackground(interval: Date(timeIntervalSinceNow: 60 * 30))
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
