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
    func prepare(tests: [[String: String]], indexPath: IndexPath) {
        let test = tests[indexPath.row]
        nameLabel.text = test["name"]!
        teachweekLabel.text = test["teachweek"]!
        dateLabel.text = test["date"]!
        placeLabel.text = test["place"]!
        timeLabel.text = test["time"]!
    }
}
