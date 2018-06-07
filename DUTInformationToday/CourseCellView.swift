//
//  CourseCellTableViewCell.swift
//  DUTInfomation
//
//  Created by shino on 2017/9/6.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit

class CourseCellView: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var teacher: UILabel!
    @IBOutlet weak var place: UILabel!
    @IBOutlet weak var week: UILabel!
    
    func prepare(fromCourse courses: [TimeData], ofIndex indexPath: IndexPath) {
        let index = indexPath.row
        let course = courses[index]
        prepare(fromCourse: course)
    }
    
    func prepareForNow(fromCourse courses: [TimeData], ofIndex indexPath: IndexPath) {
        let date = Date()
        if let course = (courses.filter { $0.startsection == date.section() }).first {
            prepare(fromCourse: course)
        } else {
            prepare(fromCourse: courses, ofIndex: indexPath)
        }
    }
    
    func prepare(fromCourse course: TimeData) {
        name.text = course.course.name
        teacher.text = course.course.teacher
        place.text = course.place
        week.text = "第\(course.startsection)节"
    }
}
