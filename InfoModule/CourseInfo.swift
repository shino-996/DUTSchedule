//
//  CourseInfo.swift
//  DUTInformationToday
//
//  Created by shino on 2017/9/27.
//  Copyright © 2017年 shino. All rights reserved.
//

import Foundation
import DUTInfo

class CourseInfo: NSObject {
    private var fileURL: URL
    
    var allCourses: [[String: String]]? {
        get {
            return allCourseData
        }
        set {
            guard let courses = newValue else {
                return
            }
            allCourseData = courses
            (courses as NSArray).write(to: self.fileURL, atomically: true)
        }
    }
    private var allCourseData: [[String: String]]?
    
    override init() {
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")
        fileURL = groupURL!.appendingPathComponent("course.plist")
        guard let array = NSArray(contentsOf: fileURL) as? [[String: String]] else {
            allCourseData = nil
            return
        }
        allCourseData = array
    }
    
    static func deleteCourse() {
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")
        let fileURL = groupURL!.appendingPathComponent("course.plist")
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    func loadCoursesAsync(_ handler: (() -> Void)?) {
        let (studentNumber, teachPassword, portalPassword) = KeyInfo.shared.getAccount()!
        DispatchQueue.global().async {
            guard let courses = DUTInfo(studentNumber: studentNumber,
                                        teachPassword: teachPassword,
                                        portalPassword: portalPassword).courseInfo() else {
                return
            }
            (courses as NSArray).write(to: self.fileURL, atomically: true)
            self.allCourseData = courses
            handler?()
        }
    }
    
    private func coursesAWeek(_ date: Date) -> (courses: [[String: String]]?, weeknumber: Int) {
        let weeknumberDataFormatter = DateFormatter()
        weeknumberDataFormatter.dateFormat = "w"
        let weeknumber = Int(weeknumberDataFormatter.string(from: date))! - 9
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
    
    func coursesThisWeek(_ date: Date = Date()) -> (courses: [[String: String]]?, weeknumber: Int, date: Date) {
        let tuple = coursesAWeek(date)
        return (tuple.courses, tuple.weeknumber, date)
    }
    
    func coursesNextWeek(_ date: Date = Date()) -> (courses: [[String: String]]?, weeknumber: Int, date: Date) {
        let nextDate = date.addingTimeInterval(7 * 60 * 60 * 24)
        let tuple = coursesAWeek(nextDate)
        return (tuple.courses, tuple.weeknumber, nextDate)
    }
    
    func coursesLastWeek(_ date: Date = Date()) -> (courses: [[String: String]]?, weeknumber: Int, date: Date) {
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
    
    func coursesToday(_ date: Date = Date()) -> (courses: [[String: String]]?, weeknumber: Int, week: Int, date: Date) {
        let tuple = coursesADay(date)
        return (tuple.courses, tuple.weeknumber, tuple.week, date)
    }
    
    func coursesNextDay(_ date: Date = Date()) -> (courses: [[String: String]]?, weeknumber: Int, week: Int, date: Date) {
        let nextDate = date.addingTimeInterval(60 * 60 * 24)
        let tuple = coursesADay(nextDate)
        return (tuple.courses, tuple.weeknumber, tuple.week, nextDate)
    }
    
    func coursesLastDay(_ date: Date = Date()) -> (courses: [[String: String]]?, weeknumber: Int, week: Int, date: Date) {
        let lastDate = date.addingTimeInterval(-60 * 60 * 24)
        let tuple = coursesADay(lastDate)
        return (tuple.courses, tuple.weeknumber, tuple.week, lastDate)
    }
    
    func courseNow(_ date: Date = Date()) -> (course: [String: String]?, weeknumber: Int, week: Int, date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HHmm"
        let time = Int(dateFormatter.string(from: date))!
        var coursenumber = 0
        if time < 0935 {
            coursenumber = 1
        } else if time < 1140 {
            coursenumber = 3
        } else if time < 1505 {
            coursenumber = 5
        } else if time < 1710 {
            coursenumber = 7
        } else {
            coursenumber = Int.max
        }
        let tuple = coursesADay(date)
        guard let courses = tuple.courses else {
            return (nil, tuple.weeknumber, tuple.week, date)
        }
        var nowCourse: [String: String]?
        for course in courses {
            let number = Int(course["coursenumber"]!)!
            if number >= coursenumber {
                nowCourse = course
                break
            }
        }
        return (nowCourse, tuple.weeknumber, tuple.week, date)
    }
}
