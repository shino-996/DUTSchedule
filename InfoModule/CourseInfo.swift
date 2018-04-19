//
//  CourseInfo.swift
//  DUTInformationToday
//
//  Created by shino on 2017/9/27.
//  Copyright © 2017年 shino. All rights reserved.
//

import Foundation
import DUTInfo
import CoreData

struct CourseData: CourseType {
    var name: String
    var teacher: String
    
    typealias TimeType = TimeData
    var time: [TimeData]
}

struct TimeData: CourseTimeType {
    var place: String
    var startSection: Int
    var endSection: Int
    var week: Int
    var teachWeek: [Int]
}

class Course: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var teacher: String
    @NSManaged var time: Set<Time>
    
    static func fetchRequest() -> NSFetchRequest<Course> {
        return NSFetchRequest<Course>(entityName: "Course")
    }
    
    func config(from data: CourseData, context: NSManagedObjectContext) {
        name = data.name
        teacher = data.teacher
        for timeData in data.time {
            let newTime = NSEntityDescription.insertNewObject(forEntityName: "Time", into: context) as! Time
            newTime.place = timeData.place
            newTime.startsection = timeData.startSection
            newTime.endsection = timeData.endSection
            newTime.week = timeData.week
            newTime.teachweek = timeData.teachWeek
            newTime.course = self
        }
    }
}

class Time: NSManagedObject {
    @NSManaged var place: String
    @NSManaged var startsection: Int
    @NSManaged var endsection: Int
    @NSManaged var week: Int
    @NSManaged var teachweek: [Int]
    @NSManaged var course: Course
    
    static func fetchRequest() -> NSFetchRequest<Time> {
        return NSFetchRequest<Time>(entityName: "Time")
    }
}

class CourseInfo: NSObject {
    var context: NSManagedObjectContext!
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    static func deleteCourse() {}
    
    func loadCoursesAsync(_ handler: (() -> Void)?) {
        let (studentNumber, teachPassword, portalPassword) = KeyInfo.shared.getAccount()!
        DispatchQueue.global().async {
            guard let coursesData: [CourseData] = DUTInfo(studentNumber: studentNumber,
                                        teachPassword: teachPassword,
                                        portalPassword: portalPassword).courseInfo() else {
                return
            }
            let fetchRequest: NSFetchRequest<Course> = Course.fetchRequest()
            let courses = try! self.context.fetch(fetchRequest)
            for courseData in coursesData {
                if courses.filter({ return $0.name == courseData.name }).count != 0 {
                    break
                } else {
                    let newCourse = NSEntityDescription.insertNewObject(forEntityName: "Course", into: self.context) as! Course
                    newCourse.config(from: courseData, context: self.context)
                }
            }
            try! self.context.save()
            handler?()
        }
    }
    
    func addCourse(_ courses: [[String: String]]) {}
    
    private func coursesAWeek(_ date: Date) -> (courses: [[String: String]]?, weeknumber: Int) {
        let weeknumberDataFormatter = DateFormatter()
        weeknumberDataFormatter.dateFormat = "w"
        let weeknumber = Int(weeknumberDataFormatter.string(from: date))! - 9
        let fetchRequest: NSFetchRequest<Time> = Time.fetchRequest()
        let times = try! context.fetch(fetchRequest)
        let courses = times.filter { time in
            guard time.startsection != 0 else {
                return false
            }
            return time.teachweek.contains(weeknumber)
        }
        var values: [[String: String]]?
        for course in courses {
            var value = [String: String]()
            value["name"] = course.course.name
            value["teacher"] = course.course.teacher
            value["place"] = course.place
            value["coursenumber"] = "\(course.startsection)"
            value["week"] = "\(course.week)"
            value["weeknumber"] = "\(course.teachweek.first!)-\(course.teachweek.last!)"
            if values == nil {
                values = [[String: String]]()
            }
            values!.append(value)
        }
        return (values, weeknumber)
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
