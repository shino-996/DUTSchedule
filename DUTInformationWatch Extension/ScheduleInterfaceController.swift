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
    var dataManager: DataManager!
    var rowTypes: [ScheduleRowType] = []
    
    override func awake(withContext context: Any?) {
        guard let dataManager = context as? DataManager else {
            fatalError("context type error")
        }
        self.dataManager = dataManager
    }
    
    override func willActivate() {
        if scheduleTable.numberOfRows != 0 {
            return
        }
        let date = Date()
        let allCourse = dataManager.courses(of: .thisWeek(date))
        for week in 1 ... 7 {
            let courses = allCourse.filter { $0.weekday == week }
            for i in 0 ..< courses.count {
                if i == 0 {
                    let rowIndex = rowTypes.count
                    rowTypes.append(.WeekRow)
                    scheduleTable.insertRows(at: [rowIndex], withRowType: "WeekRow")
                    let row = scheduleTable.rowController(at: rowIndex) as! WeekRow
                    row.prepare(teachweek: date.teachweek(), weekday: week)
                }
                let rowIndex = rowTypes.count
                rowTypes.append(.CourseRow)
                scheduleTable.insertRows(at: [rowIndex], withRowType: "CourseRow")
                let row = scheduleTable.rowController(at: rowIndex) as! CourseRow
                row.prepare(course: courses[i])
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if rowTypes[rowIndex] == .CourseRow {
            let course = (table.rowController(at: rowIndex) as! CourseRow).course!
            presentController(withName: "CourseInterface", context: course.course)
        }
    }
}

extension ScheduleInterfaceController {
    enum ScheduleRowType: String {
        case WeekRow
        case CourseRow
    }
}
