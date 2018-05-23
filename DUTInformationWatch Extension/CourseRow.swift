//
//  CourseRow.swift
//  DUTInformationWatch Extension
//
//  Created by shino on 08/03/2018.
//  Copyright © 2018 shino. All rights reserved.
//

import WatchKit

class CourseRow: NSObject {
    @IBOutlet var courseLabel: WKInterfaceLabel!
    @IBOutlet var placeLabel: WKInterfaceLabel!
    
    func prepare(time: TimeData) {
        let courseText = "第\(time.startsection)节" + "   " + time.course.name
        let placeText = time.place
        courseLabel.setText(courseText)
        placeLabel.setText(placeText)
    }
}
