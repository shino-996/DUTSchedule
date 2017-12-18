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
        let line = indexPath.item % 8
        let row = Int(indexPath.item / 8)
        let coursenumber = ((row + 1) / 2) * 2 - 1
        let week = line - 1
        let course = courseData.filter {
            $0["week"] ?? "" == "\(week)" && $0["coursenumber"] == "\(coursenumber)"
        }
        courseLabel.text = course.first?["name"] ?? ""
    }
}
