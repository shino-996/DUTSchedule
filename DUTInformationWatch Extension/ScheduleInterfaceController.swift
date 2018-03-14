//
//  ScheduleInterfaceController.swift
//  DUTInformationWatch Extension
//
//  Created by shino on 14/03/2018.
//  Copyright © 2018 shino. All rights reserved.
//

import WatchKit
import Foundation


class ScheduleInterfaceController: WKInterfaceController {
    @IBOutlet var scheduleTable: WKInterfaceTable!
    let courseInfo = CourseInfo()
    var date = Date()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        loadSchedule()
    }
    
    func loadSchedule() {
        for index in 0 ..< scheduleTable.numberOfRows {
            scheduleTable.removeRows(at: [index])
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "e"
        let weekToday = Int(dateFormatter.string(from: date))! - 1
        for week in 1 ... 7 {
            let tuple = courseInfo.coursesThisWeek(date)
            let weeknumber = tuple.weeknumber
            let dateInterval = week - weekToday
            let requestDate = Date(timeIntervalSinceNow: TimeInterval(dateInterval * 24 * 60 * 60))
            let courses = courseInfo.coursesToday(requestDate).courses!
            if courses.count != 0 {
                scheduleTable.insertRows(at: [scheduleTable.numberOfRows], withRowType: "WeekRow")
                (scheduleTable.rowController(at: scheduleTable.numberOfRows - 1) as! WeekRow).weekLabel.setText("第\(weeknumber)周 周\(week)")
            }
            for course in courses {
                scheduleTable.insertRows(at: [scheduleTable.numberOfRows], withRowType: "CourseRow")
                (scheduleTable.rowController(at: scheduleTable.numberOfRows - 1) as! CourseRow).prepare(course: course)
            }
        }
    }
}
