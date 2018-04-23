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
    
    func prepare(course: TimeData) {
        let courseText = "第\(course.startsection)节" + "   " + course.course.name
        let placeText = course.place
        courseLabel.setText(courseText)
        placeLabel.setText(placeText)
    }
}
