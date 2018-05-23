//
//  CourseInterfaceController.swift
//  DUTInformationWatch Extension
//
//  Created by shino on 2018/5/23.
//  Copyright © 2018 shino. All rights reserved.
//

import WatchKit
import Foundation


class CourseInterfaceController: WKInterfaceController {
    @IBOutlet var nameLabel: WKInterfaceLabel!
    @IBOutlet var teacherLabel: WKInterfaceLabel!
    @IBOutlet var timeTable: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        guard let course = context as? CourseData else {
            fatalError()
        }
        nameLabel.setText(course.name)
        teacherLabel.setText(course.teacher)
        guard let times = course.time else {
            return
        }
        for time in times {
            timeTable.insertRows(at: [timeTable.numberOfRows], withRowType: "TimeRow")
            (timeTable.rowController(at: timeTable.numberOfRows - 1) as! TimeRow).prepare(time: time)
        }
    }

}
