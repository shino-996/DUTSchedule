//
//  WeekCell.swift
//  DUTInfomation
//
//  Created by shino on 12/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import UIKit

class WeekCell: UICollectionViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weekDayLabel: UILabel!
    
    func prepare(date: Date, indexPath: IndexPath) {
        let chineseWeek = ["日", "一", "二", "三", "四", "五", "六"]
        weekDayLabel.text = "周\(chineseWeek[indexPath.item - 1])"
        let weekDateFormatter = DateFormatter()
        weekDateFormatter.dateFormat = "e"
        let nowWeek = Int(weekDateFormatter.string(from: date))!
        let nowDate = date.addingTimeInterval(Double((indexPath.item - nowWeek) * 60 * 60 * 24))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd日"
        dateLabel.text = dateFormatter.string(from: nowDate)
    }
}
