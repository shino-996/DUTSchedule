//
//  TestCell.swift
//  DUTInfomation
//
//  Created by shino on 18/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import UIKit

class TestCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var teachweekLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    func prepare(tests: [TestData], indexPath: IndexPath) {
        let test = tests[indexPath.section]
        nameLabel.text = test.name
        teachweekLabel.text = "第\(test.date.teachweek())周周\(test.date.weekDayStr())"
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 8)
        dateFormatter.dateFormat = "MM-dd"
        dateLabel.text = dateFormatter.string(from: test.date)
        placeLabel.text = test.place
        
        dateFormatter.dateFormat = "HH:mm"
        timeLabel.text = dateFormatter.string(from: test.starttime)
                        + "-"
                        + dateFormatter.string(from: test.endtime)
        layer.cornerRadius = 10
    }
}
