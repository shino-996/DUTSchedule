//
//  CourseCell.swift
//  DUTInfomation
//
//  Created by shino on 12/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import UIKit

class CourseCell: UICollectionViewCell {
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var addLabel: UILabel!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func prepare(courses: [TimeData], indexPath: IndexPath) {
        addLabel.isHidden = true
        let course = getCourse(courses, indexPath)
        if let courseName = course?.course.name {
            courseLabel.isHidden = false
            backgroundColor = UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.7)
            courseLabel.text = courseName
        } else {
            courseLabel.isHidden = true
            backgroundColor = .clear
        }
        NotificationCenter.default.addObserver(forName: "space.shino.post.addcourse") { [unowned self] _ in
            if self.addLabel.isHidden == false {
                self.addLabel.isHidden = true
                self.backgroundColor = .clear
            }
        }
    }
    
    func courseInfo(courses: [TimeData], indexPath: IndexPath) -> String? {
        guard let course = getCourse(courses, indexPath) else {
            return nil
        }
        return """
        \(course.course.name)
        \(course.course.teacher)
        \(course.startweek)周
        周\(Date.weekDay(of: Int(course.weekday)))
        第\(course.startsection)节
        \(course.place)
        """
    }
    
    private func getCourse(_ courses: [TimeData], _ indexPath: IndexPath) -> TimeData? {
        let line = indexPath.item % 8
        let row = Int(indexPath.item / 8)
        let coursenumber = ((row + 1) / 2) * 2 - 1
        let week = line - 1
        let course = courses.filter {
            $0.weekday == week && $0.startsection == coursenumber
        }.first
        return course
    }
}
