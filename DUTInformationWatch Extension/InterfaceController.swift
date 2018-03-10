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


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet var informationTable: WKInterfaceTable!
    
    var courseData: [[String: String]]?
    let session = WCSession.default
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
        courseData = CourseInfo().coursesToday(Date()).courses
        prepareOtherInfo()
        prepareCourse()
    }
    
    func prepareOtherInfo() {
        informationTable.insertRows(at: [0], withRowType: "NetRow")
        informationTable.insertRows(at: [1], withRowType: "EcardRow")
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")
        let flow = userDefaults?.string(forKey: "flow") ?? ""
        let cost = userDefaults?.string(forKey: "cost") ?? ""
        (informationTable.rowController(at: 0) as? NetRow)?.prepare(flow: flow, cost: cost)
        let ecard = userDefaults?.string(forKey: "ecard") ?? ""
        (informationTable.rowController(at: 1) as? EcardRow)?.prepare(ecard: ecard)
    }
    
    func prepareCourse() {
        for i in 2 ..< 2 + (courseData?.count ?? 0) {
            informationTable.insertRows(at: [i], withRowType: "CourseRow")
            let row = informationTable.rowController(at: i) as! CourseRow
            row.prepare(course: courseData![i - 2])
        }
    }
    
    override func willActivate() {
        super.willActivate()
        if courseData == nil {
            informationTable.removeRows(at: [0, 1])
            informationTable.insertRows(at: [0], withRowType: "SyncRow")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState != .activated {
            if let error = error {
                print(error)
            }
            return
        }
        if courseData != nil {
            return
        }
        let message = ["message": "Sync request"]
        session.sendMessage(message, replyHandler: nil, errorHandler: { error in
            print("Watch request error!")
            print(error)
        })
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if courseData != nil {
            return
        }
        guard let course = message["course"] as? [[String: String]] else {
            return
        }
        var courseInfo = CourseInfo()
        courseInfo.allCourseData = course
        courseData = courseInfo.coursesToday(Date()).courses
        informationTable.removeRows(at: [0])
        prepareOtherInfo()
        prepareCourse()
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        guard let message = applicationContext as? [String: String] else {
            return
        }
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")
        userDefaults?.setValue(message["flow"] ?? "", forKey: "flow")
        userDefaults?.setValue(message["cost"] ?? "", forKey: "cost")
        userDefaults?.setValue(message["ecard"] ?? "", forKey: "ecard")
        userDefaults?.synchronize()
        print("recieved background message")
    }
}
