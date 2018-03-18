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
    var data: (courses: [[String: String]]?, weeknumber: Int, week: Int, date: Date)
    
    init(data: (courses: [[String: String]]?, weeknumber: Int, week: Int, date: Date)) {
        self.data = data
    }
    
    weak var controller: UIViewController!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard data.courses != nil else {
            return 0
        }
        return data.courses!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as! CourseCellView
        if indexPath.row == 0 &&
            controller.extensionContext?.widgetActiveDisplayMode == .compact{
            cell.prepareForNow(fromCourse: data.courses!, ofIndex: indexPath)
        } else {
            cell.prepare(fromCourse: data.courses!, ofIndex: indexPath)
        }
        return cell
    }
}
