//
//  WeekRow.swift
//  DUTInformationWatch Extension
//
//  Created by shino on 14/03/2018.
//  Copyright © 2018 shino. All rights reserved.
//

import WatchKit

class WeekRow: NSObject {
    @IBOutlet var weekLabel: WKInterfaceLabel!
    
    func prepare(teachweek: Int, weekday: Int) {
        weekLabel.setText("第\(teachweek)周 周\(weekday)")
    }
}
