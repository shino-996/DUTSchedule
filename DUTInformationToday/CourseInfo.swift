//
//  CourseInfo.swift
//  DUTInformationToday
//
//  Created by shino on 2017/9/27.
//  Copyright © 2017年 shino. All rights reserved.
//

import Foundation

protocol CourseInfoDelegate {
    func courseDidChange(courses: [[String: String]], week: String)
}

class CourseInfo: NSObject {
    var delegate: CourseInfoDelegate!
    var date = Date()
    var weekString: String!
    var courseData: [[String: String]]!
    var allCourseData: [[String: String]]!
    
    init(dutInfo: DUTInfo) {
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")
        let fileURL = groupURL!.appendingPathComponent("course.plist")
        let array = NSArray(contentsOf: fileURL)
        guard array != nil else {
            dutInfo.scheduleInfo()
            return
        }
        allCourseData = array as! [[String: String]]
    }
    
    private func getCourseData() {
        let weekDateFormatter = DateFormatter()
        weekDateFormatter.dateFormat = "e"
        let week = String(Int(weekDateFormatter.string(from: date))! - 1)
        let weeknumberDateFormatter = DateFormatter()
        weeknumberDateFormatter.dateFormat = "w"
        let weeknumber = Int(weeknumberDateFormatter.string(from: date))! - 35
        courseData = allCourseData.filter { (course: [String: String]) -> Bool in
            let courseWeek = course["week"]!
            if courseWeek != week {
                return false
            }
            let courseWeeknumber = course["weeknumber"]!.components(separatedBy: "-")
            let courseStartWeeknumber = Int(courseWeeknumber[0])!
            let courseEndWeeknumber = Int(courseWeeknumber[1])!
            if weeknumber >= courseStartWeeknumber && weeknumber <= courseEndWeeknumber {
                return true
            } else {
                return false
            }
            }.sorted {
                $0["coursenumber"]! <= $1["coursenumber"]!
        }
        let chineseWeek = ["0": "日",
                           "1": "一",
                           "2": "二",
                           "3": "三",
                           "4": "四",
                           "5": "五",
                           "6": "六"]
        weekString = "第\(weeknumber)周 周\(chineseWeek[week]!)"
        delegate.courseDidChange(courses: courseData, week: weekString)
    }
    
    func getTodayCourseData() {
        date = Date()
        getCourseData()
    }
    
    func getNextDayCourseData() {
        date = date.addingTimeInterval(60 * 60 * 24)
        getCourseData()
    }
    
    func getPreviousDayCourseData() {
        date = date.addingTimeInterval(-60 * 60 * 24)
        getCourseData()
    }
}
