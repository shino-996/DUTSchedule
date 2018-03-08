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
        courseData = CourseInfo().coursesToday(Date()).courses
        prepareCourse()
    }
    
    func prepareCourse() {
        informationTable.setNumberOfRows(courseData?.count ?? 0, withRowType: "CourseRow")
        for i in 0 ..< informationTable.numberOfRows {
            let row = informationTable.rowController(at: i) as! CourseRow
            row.prepare(course: courseData![i])
        }
    }
    
    override func willActivate() {
        super.willActivate()
        if courseData == nil {
            if WCSession.isSupported() {
                session.delegate = self
                session.activate()
            }
            informationTable.setNumberOfRows(1, withRowType: "SyncRow")
            return
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState != .activated {
            if let error = error {
                print(error)
            }
            return
        }
        let message = ["message": "Sync request"]
        session.sendMessage(message, replyHandler: nil, errorHandler: { error in
            print("Watch request error!")
            print(error)
        })
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let course = message["course"] as? [[String: String]] else {
            return
        }
        var courseInfo = CourseInfo()
        courseInfo.allCourseData = course
        courseData = courseInfo.coursesToday(Date()).courses
        informationTable.removeRows(at: [0])
        prepareCourse()
    }
}
