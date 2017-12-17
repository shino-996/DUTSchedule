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
    var allCourseData: [[String: String]]? {
        didSet {
            guard let courses = allCourseData else {
                return
            }
            let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")
            let fileURL = groupURL!.appendingPathComponent("course.plist")
            (courses as NSArray).write(to: fileURL, atomically: true)
        }
    }
    
    init() {
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")
        let fileURL = groupURL!.appendingPathComponent("course.plist")
        guard let array = NSArray(contentsOf: fileURL) else {
            allCourseData = nil
            return
        }
        allCourseData = (array as! [[String: String]])
    }
    
    private mutating func courseDataAWeek() -> (courses: [[String: String]]?, weeknumber: Int) {
        let weeknumberDataFormatter = DateFormatter()
        weeknumberDataFormatter.dateFormat = "w"
        let weeknumber = Int(weeknumberDataFormatter.string(from: date))! - 35
        guard allCourseData != nil else {
            return (nil, weeknumber)
        }
        let courses = allCourseData!.filter { course in
            guard course["coursenumber"] != "" else {
                return false
            }
            let courseWeeknumber = course["weeknumber"]!.components(separatedBy: "-")
            let courseStartWeeknumber = Int(courseWeeknumber[0])!
            let courseEndWeeknumber = Int(courseWeeknumber[1])!
            return  weeknumber >= courseStartWeeknumber && weeknumber <= courseEndWeeknumber
        }
        return (courses, weeknumber)
    }
    
    mutating func courseDataThisWeek() -> (courses: [[String: String]]?, weeknumber: Int) {
        date = Date()
        return courseDataAWeek()
    }
    
    mutating func courseDataNextWeek() -> (courses: [[String: String]]?, weeknumber: Int) {
        date = date.addingTimeInterval(7 * 60 * 60 * 24)
        return courseDataAWeek()
    }
    
    mutating func courseDataLastWeek() -> (courses: [[String: String]]?, weeknumber: Int) {
        date = date.addingTimeInterval(-7 * 60 * 60 * 24)
        return courseDataAWeek()
    }
    
    mutating private func courseDataADay() -> (courses: [[String: String]]?, weeknumber: Int, week: Int) {
        let (coursesAWeek, weeknumber) = courseDataAWeek()
        let weekDateFormatter = DateFormatter()
        weekDateFormatter.dateFormat = "e"
        let week = Int(weekDateFormatter.string(from: date))! - 1
        guard coursesAWeek != nil else {
            return (nil, weeknumber, week)
        }
        let courses = coursesAWeek!.filter {
            $0["week"]! == String(week)
        }.sorted {
            $0["coursenumber"]! <= $1["coursenumber"]!
        }
        return (courses, weeknumber, week)
    }
    
    mutating func courseDataToday() -> (courses: [[String: String]]?, weeknumber: Int, week: Int) {
        date = Date()
        return courseDataADay()
    }
    
    mutating func courseDataNextDay() -> (courses: [[String: String]]?, weeknumber: Int, week: Int) {
        date = date.addingTimeInterval(60 * 60 * 24)
        return courseDataADay()
    }
    
    mutating func courseDayLastDay() -> (courses: [[String: String]]?, weeknumber: Int, week: Int) {
        date = date.addingTimeInterval(-60 * 60 * 24)
        return courseDataADay()
    }
}
