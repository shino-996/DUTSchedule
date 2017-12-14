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
    
    func prepare(courseData: [[String: String]]?, indexPath: IndexPath) {
        guard let courseData = courseData  else {
            courseLabel.text = ""
            return
        }
        let coursenumber = ((indexPath.section + 1) / 2) * 2 - 1
        let week = indexPath.item - 1
        let course = courseData.filter {
            $0["week"] ?? "" == "\(week)" && $0["coursenumber"] == "\(coursenumber)"
        }
//        print(course.first ?? "no course")
        courseLabel.text = course.first?["name"] ?? ""
    }
}
