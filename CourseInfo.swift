//
//  CourseInfo.swift
//  DUTInformationToday
//
//  Created by shino on 2017/9/27.
//  Copyright © 2017年 shino. All rights reserved.
//

import Foundation

struct CourseInfo {
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
    
    private func coursesAWeek(_ date: Date) -> (courses: [[String: String]]?, weeknumber: Int) {
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
    
    func coursesThisWeek(_ date: Date) -> (courses: [[String: String]]?, weeknumber: Int, date: Date) {
        let tuple = coursesAWeek(date)
        return (tuple.courses, tuple.weeknumber, date)
    }
    
    func coursesNextWeek(_ date: Date) -> (courses: [[String: String]]?, weeknumber: Int, date: Date) {
        let nextDate = date.addingTimeInterval(7 * 60 * 60 * 24)
        let tuple = coursesAWeek(nextDate)
        return (tuple.courses, tuple.weeknumber, nextDate)
    }
    
    func coursesLastWeek(_ date: Date) -> (courses: [[String: String]]?, weeknumber: Int, date: Date) {
        let lastDate = date.addingTimeInterval(-7 * 60 * 60 * 24)
        let tuple = coursesAWeek(lastDate)
        return (tuple.courses, tuple.weeknumber, lastDate)
    }
    
    private func coursesADay(_ date: Date) -> (courses: [[String: String]]?, weeknumber: Int, week: Int) {
        let (courses, weeknumber) = coursesAWeek(date)
        let weekDateFormatter = DateFormatter()
        weekDateFormatter.dateFormat = "e"
        let week = Int(weekDateFormatter.string(from: date))! - 1
        guard courses != nil else {
            return (nil, weeknumber, week)
        }
        let coursesaday = courses!.filter {
            $0["week"]! == String(week)
        }.sorted {
            $0["coursenumber"]! <= $1["coursenumber"]!
        }
        return (coursesaday, weeknumber, week)
    }
    
    func coursesToday(_ date: Date) -> (courses: [[String: String]]?, weeknumber: Int, week: Int, date: Date) {
        let tuple = coursesADay(date)
        return (tuple.courses, tuple.weeknumber, tuple.week, date)
    }
    
    func coursesNextDay(_ date: Date) -> (courses: [[String: String]]?, weeknumber: Int, week: Int, date: Date) {
        let nextDate = date.addingTimeInterval(60 * 60 * 24)
        let tuple = coursesADay(nextDate)
        return (tuple.courses, tuple.weeknumber, tuple.week, nextDate)
    }
    
    func coursesLastDay(_ date: Date) -> (courses: [[String: String]]?, weeknumber: Int, week: Int, date: Date) {
        let lastDate = date.addingTimeInterval(-60 * 60 * 24)
        let tuple = coursesADay(lastDate)
        return (tuple.courses, tuple.weeknumber, tuple.week, lastDate)
    }
}
