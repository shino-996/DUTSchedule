//
//  CourseNumberCell.swift
//  DUTInfomation
//
//  Created by shino on 12/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import UIKit

class CourseNumberCell: UICollectionViewCell {
    @IBOutlet weak var courseNumberLabel: UILabel!
    
    func prepare(indexPath: IndexPath) {
        courseNumberLabel.text = "\(indexPath.section)"
    }
    
    func prepare(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M"
        courseNumberLabel.text = "\(dateFormatter.string(from: date))\n月"
    }
}
