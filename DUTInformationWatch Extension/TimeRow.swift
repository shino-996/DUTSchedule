//
//  TimeRow.swift
//  DUTInformationWatch Extension
//
//  Created by shino on 2018/5/23.
//  Copyright © 2018 shino. All rights reserved.
//

import WatchKit

class TimeRow: NSObject {
    @IBOutlet var timeLabel: WKInterfaceLabel!
    @IBOutlet var placeLabel: WKInterfaceLabel!
    
    func prepare(time: TimeData) {
        let timeText = "\(time.teachweek.first!)-\(time.teachweek.last!)周 周\(time.week) 第\(time.startsection)节"
        timeLabel.setText(timeText)
        placeLabel.setText(time.place)
    }
}
