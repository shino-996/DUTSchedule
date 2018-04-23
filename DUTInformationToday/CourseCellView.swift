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
    
    func prepare(fromCourse courseInfo: [TimeData], ofIndex indexPath: IndexPath) {
        let index = indexPath.row
        let cellCourse = courseInfo[index]
        name.text = cellCourse.course.name
        teacher.text = cellCourse.course.teacher
        let placeStr = cellCourse.place
        place.text = placeStr
        week.text = "第\(cellCourse.startsection)节"
    }
    
    func prepareForNow(fromCourse courseInfo: [TimeData], ofIndex indexPath: IndexPath) {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HHmm"
        let time = Int(dateFormatter.string(from: date))!
        let index = indexPath.row
        var cellCourse = courseInfo[index]
        for course in courseInfo {
            switch course.startsection {
            case 1:
                if time <= 0935 {
                    cellCourse = course
                }
            case 3:
                if time >= 0935 && time <= 1140 {
                    cellCourse = course
                }
            case 5:
                if time >= 1140 && time <= 1505 {
                    cellCourse = course
                }
            case 7:
                if time >= 1505 && time <= 1710 {
                    cellCourse = course
                }
            default:
                break
            }
        }
        name.text = cellCourse.course.name
        teacher.text = cellCourse.course.teacher
        let placeStr = cellCourse.place
        place.text = placeStr
        week.text = "第\(cellCourse.startsection)节"
    }
}
