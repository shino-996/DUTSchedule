//
//  CourseInfo.swift
//  DUTInformationToday
//
//  Created by shino on 2017/9/27.
//  Copyright © 2017年 shino. All rights reserved.
//

import Foundation

protocol CourseInfoDelegate {
    func courseDidSet(courses: [[String: String]], week: String)
    func courseDidChange(courses: [[String: String]], week: String)
}

class CourseInfo: NSObject {
    var dutInfo: DUTInfo!
    var delegate: CourseInfoDelegate!
    lazy var date = Date()
    var weekStr: String!
    var courseData: [[String: String]]!
    var allCourseData: [[String: String]]! {
        didSet {
            getCourseData()
        }
    }
    
    init(dutInfo: DUTInfo) {
        super.init()
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")
        let fileURL = groupURL!.appendingPathComponent("course.plist")
        let array = NSArray(contentsOf: fileURL)
        guard array != nil else {
            dutInfo.scheduleInfo()
            return
        }
        allCourseData = array as! [[String: String]]
    }
    
    func getCourseData() {
        let weekDateFormatter = DateFormatter()
        weekDateFormatter.dateFormat = "e"
        let week = String(Int(weekDateFormatter.string(from: date))! - 1)
        let weeknumberDateFormatter = DateFormatter()
        weeknumberDateFormatter.dateFormat = "w"
        let weeknumber = Int(weeknumberDateFormatter.string(from: date))! - 35
        courseData = allCourseData.filter { (course: [String: String]) -> Bool in
            let weekStr = course["week"]!
            if String(weekStr) != week {
                return false
            }
            let weeknumberStr = course["weeknumber"]!.components(separatedBy: "-")
            let startWeek = Int(weeknumberStr[0])!
            let endWeek = Int(weeknumberStr[1])!
            if weeknumber >= startWeek && weeknumber <= endWeek {
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
        weekStr = "第\(weeknumber)周 周\(chineseWeek[week]!)"
        delegate.courseDidChange(courses: courseData, week: weekStr)
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
