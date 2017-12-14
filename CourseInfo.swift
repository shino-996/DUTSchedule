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
    var teachWeek: String!
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
    
    private mutating func courseDataAWeek() {
        guard let allCourseData = allCourseData else {
            courseData = nil
            return
        }
        let weeknumberDataFormatter = DateFormatter()
        weeknumberDataFormatter.dateFormat = "w"
        let weeknumber = Int(weeknumberDataFormatter.string(from: date))! - 35
        teachWeek = String(weeknumber)
        courseData = allCourseData.filter { course in
            guard course["coursenumber"] != "第节" else {
                return false
            }
            let courseWeeknumber = course["weeknumber"]!.components(separatedBy: "-")
            let courseStartWeeknumber = Int(courseWeeknumber[0])!
            let courseEndWeeknumber = Int(courseWeeknumber[1])!
            return  weeknumber >= courseStartWeeknumber && weeknumber <= courseEndWeeknumber
        }
    }
    
    mutating func courseDataThisWeek() {
        date = Date()
        courseDataAWeek()
    }
    
    mutating func courseDataNextWeek() {
        date = date.addingTimeInterval(7 * 60 * 60 * 24)
        courseDataAWeek()
    }
    
    mutating func courseDataLastWeek(){
        date = date.addingTimeInterval(-7 * 60 * 60 * 24)
        courseDataAWeek()
    }
    
    mutating private func courseDataADay() {
        courseDataADay()
        guard let courseThisWeek = courseData else {
            courseData = nil
            return
        }
        let weekDateFormatter = DateFormatter()
        weekDateFormatter.dateFormat = "e"
        let week = String(Int(weekDateFormatter.string(from: date))! - 1)
        courseData = courseThisWeek.filter {
            $0["week"]! == week
        }.sorted {
            $0["coursenumber"]! <= $1["coursenumber"]!
        }
    }
    
    mutating func courseDataToday() {
        date = Date()
        courseDataADay()
    }
    
    mutating func courseDataNextDay() {
        date = date.addingTimeInterval(60 * 60 * 24)
        courseDataADay()
    }
    
    mutating func courseDayLastDay() {
        date = date.addingTimeInterval(-60 * 60 * 24)
        courseDataADay()
    }
}
