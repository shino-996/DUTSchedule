//
//  CourseInfo.swift
//  DUTInformationToday
//
//  Created by shino on 2017/9/27.
//  Copyright © 2017年 shino. All rights reserved.
//

import Foundation

struct CourseInfo {
    var date = Date()
    var weekString: String!
    var courseData: [[String: String]]?
    var allCourseData: [[String: String]]?
    
    init() {
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")
        let fileURL = groupURL!.appendingPathComponent("course.plist")
        let array = NSArray(contentsOf: fileURL)
        guard array != nil else {
            allCourseData = nil
            return
        }
        allCourseData = (array as! [[String: String]])
    }
    
    mutating private func getCourseData() {
        let weekDateFormatter = DateFormatter()
        weekDateFormatter.dateFormat = "e"
        let week = String(Int(weekDateFormatter.string(from: date))! - 1)
        let weeknumberDateFormatter = DateFormatter()
        weeknumberDateFormatter.dateFormat = "w"
        let weeknumber = Int(weeknumberDateFormatter.string(from: date))! - 35
        guard allCourseData != nil else {
            courseData = nil
            return
        }
        courseData = allCourseData!.filter { course in
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
    }
    
    mutating func getTodayCourseData() {
        date = Date()
        getCourseData()
    }
    
    mutating func getNextDayCourseData() {
        date = date.addingTimeInterval(60 * 60 * 24)
        getCourseData()
    }
    
    mutating func getPreviousDayCourseData() {
        date = date.addingTimeInterval(-60 * 60 * 24)
        getCourseData()
    }
}
