//
//  AddCourseController.swift
//  DUTInfomation
//
//  Created by shino on 24/03/2018.
//  Copyright © 2018 shino. All rights reserved.
//

import UIKit

protocol AddCourseDelegate {
    func addCourse(_ course: [String: String])
}

class AddCourseController: UITableViewController {
    var delegate: AddCourseDelegate?
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if section == 1 {
            return 1
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            return tableView.dequeueReusableCell(withIdentifier: "AddCourseTimeCell") as! AddCourseTimeCell
        }
        if indexPath.section == 2 {
            return tableView.dequeueReusableCell(withIdentifier: "ConfirmCell")!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddCourseCell") as! AddCourseCell
        let row = indexPath.row
        var string: String
        switch row {
        case 0:
            string = "课程名"
        case 1:
            string = "上课教师"
        case 2:
            string = "上课地点"
        default:
            string = ""
        }
        cell.prepare(string)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 2 {
            return
        }
        let keys = ["name", "teacher", "place"]
        var course = [String: String]()
        for i in 0 ..< 3 {
            course.updateValue((tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! AddCourseCell).courseInfoText.text ?? "",
                               forKey: keys[i])
        }
        let dictionary = (tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! AddCourseTimeCell).courseText()
        for element in dictionary {
            course[element.key] = dictionary[element.key]
        }
        delegate?.addCourse(course)
        self.dismiss(animated: true)
    }
}
