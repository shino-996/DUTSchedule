//
//  TodayViewDataSource.swift
//  DUTInformationToday
//
//  Created by shino on 18/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewDataSource: NSObject, UITableViewDataSource {
    var courses: [TimeData]
    var date: Date
    
    init(courses: [TimeData], date: Date) {
        self.courses = courses
        self.date = date
    }
    
    weak var controller: UIViewController!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as! CourseCellView
        if indexPath.row == 0
            && controller.extensionContext?.widgetActiveDisplayMode == .compact{
            cell.prepareForNow(fromCourse: courses, ofIndex: indexPath)
        } else {
            cell.prepare(fromCourse: courses, ofIndex: indexPath)
        }
        return cell
    }
}
