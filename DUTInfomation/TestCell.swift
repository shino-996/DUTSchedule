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
        teachweekLabel.text = "\(test.date.teachweek())"
        dateLabel.text = "\(test.date)"
        placeLabel.text = test.place
        timeLabel.text = "\(test.starttime)"
        layer.cornerRadius = 10
    }
}
