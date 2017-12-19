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
    
    func prepare(courses: [[String: String]]?, indexPath: IndexPath) {
        let course = getCourse(courses, indexPath)
        courseLabel.text = course?["name"] ?? ""
        layer.cornerRadius = 5
    }
    
    func courseInfo(courses: [[String: String]]?, indexPath: IndexPath) -> String? {
        guard let course = getCourse(courses, indexPath) else {
            return nil
        }
        let chineseWeek = ["日", "一", "二", "三", "四", "五", "六"]
        return """
        \(course["name"]!)
        \(course["teacher"]!)
        \(course["weeknumber"]!)周
        周\(course["week"]!)
        第\(chineseWeek[Int(course["coursenumber"]!)!])节
        \(course["place"]!)
        """
    }
    
    private func getCourse(_ courses: [[String : String]]?, _ indexPath: IndexPath) -> [String: String]? {
        guard let courses = courses  else {
            courseLabel.text = ""
            return nil
        }
        let line = indexPath.item % 8
        let row = Int(indexPath.item / 8)
        let coursenumber = ((row + 1) / 2) * 2 - 1
        let week = line - 1
        let course = courses.filter {
            $0["week"] ?? "" == "\(week)" && $0["coursenumber"] == "\(coursenumber)"
        }.first
        return course
    }
}
