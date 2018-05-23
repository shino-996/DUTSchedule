//
//  ScheduleInterfaceController.swift
//  DUTInformationWatch Extension
//
//  Created by shino on 14/03/2018.
//  Copyright © 2018 shino. All rights reserved.
//

import WatchKit
import Foundation
import CoreData

class ScheduleInterfaceController: WKInterfaceController {
    @IBOutlet var scheduleTable: WKInterfaceTable!
    let courseManager = CourseManager()
    var timeData: [TimeData]!
    var courseIndex = [Int]()
    
    override func willActivate() {
        if scheduleTable.numberOfRows != 0 {
            return
        }
        for index in 0 ..< scheduleTable.numberOfRows {
            scheduleTable.removeRows(at: [index])
        }
        let tuple = courseManager.coursesThisWeek()
        timeData = tuple.courses
        if timeData.isEmpty {
            return
        }
        var rowIndex = -1
        for week in 1 ... 7 {
            let courses = timeData.filter { $0.week == Int64(week) }
            if courses.count != 0 {
                scheduleTable.insertRows(at: [scheduleTable.numberOfRows], withRowType: "WeekRow")
                (scheduleTable.rowController(at: scheduleTable.numberOfRows - 1) as! WeekRow).weekLabel.setText("第\(tuple.teachweek)周 周\(week)")
                rowIndex += 1
            }
            for course in courses {
                scheduleTable.insertRows(at: [scheduleTable.numberOfRows], withRowType: "CourseRow")
                (scheduleTable.rowController(at: scheduleTable.numberOfRows - 1) as! CourseRow).prepare(time: course)
                rowIndex += 1
                courseIndex.append(rowIndex)
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let courseData = timeData[courseIndex.index(of: rowIndex)!].course
        presentController(withName: "CourseInterface", context: courseData)
    }
}
