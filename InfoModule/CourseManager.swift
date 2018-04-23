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

final class CourseData: NSManagedObject {
    @NSManaged fileprivate (set) var name: String
    @NSManaged fileprivate (set) var teacher: String
    @NSManaged fileprivate (set) var time: Set<TimeData>?
}

extension CourseData: ManagedObject {
    typealias Object = Course
    
    static func insertNewObject(from course: Course, into context: NSManagedObjectContext) -> CourseData {
        let courseData = NSEntityDescription.insertNewObject(forEntityName: "CourseData", into: context) as! CourseData
        courseData.name = course.name
        courseData.teacher = course.teacher
        if let timeData = (course.time?.map() { TimeData.insertNewObject(from: $0, into: context) }) {
            courseData.time = Set(timeData)
        }
        return courseData
    }
    
    func export() -> [String: Any] {
        var dic: [String: Any] =  ["name": name, "teacher": teacher]
        if let allTimeData = time {
            dic["time"] = allTimeData.map() { $0.export() }
        }
        return dic
    }
    
    static func importData(from dic: [String: Any], into context: NSManagedObjectContext) -> CourseData {
        let courseData = NSEntityDescription.insertNewObject(forEntityName: "CourseData", into: context) as! CourseData
        courseData.name = dic["name"] as! String
        courseData.teacher = dic["teacher"] as! String
        if let timeData = ((dic["time"] as? [[String: Any]])?.map() { TimeData.importData(from: $0, into: context)}) {
            courseData.time = Set(timeData)
        } else {
            courseData.time = nil
        }
        return courseData
    }
}

final class TimeData: NSManagedObject {
    @NSManaged fileprivate (set) var place: String
    @NSManaged fileprivate (set) var startsection: Int64
    @NSManaged fileprivate (set) var endsection: Int64
    @NSManaged fileprivate (set) var week: Int64
    @NSManaged fileprivate (set) var teachweek: [Int64]
    @NSManaged fileprivate (set) var course: CourseData
}

extension TimeData: ManagedObject {
    typealias Object = Time
    
    static func insertNewObject(from time: Time, into context: NSManagedObjectContext) -> TimeData {
        let timeData = NSEntityDescription.insertNewObject(forEntityName: "TimeData", into: context) as! TimeData
        timeData.place = time.place
        timeData.startsection = Int64(time.startsection)
        timeData.endsection = Int64(time.endsection)
        timeData.week = Int64(time.week)
        timeData.teachweek = time.teachweek.map() { Int64($0) }
        return timeData
    }
    
    func export() -> [String: Any] {
        return ["place": place,
                "startsection": Int64(startsection),
                "endsection": Int64(endsection),
                "week": Int64(week),
                "teachweek": teachweek.map() { Int64($0) }]
    }
    
    static func importData(from dic: [String: Any], into context: NSManagedObjectContext) -> TimeData {
        let timeData = NSEntityDescription.insertNewObject(forEntityName: "TimeData", into: context) as! TimeData
        timeData.place = dic["place"] as! String
        timeData.startsection = dic["startsection"] as! Int64
        timeData.endsection = dic["endsection"] as! Int64
        timeData.week = dic["week"] as! Int64
        timeData.teachweek = dic["teachweek"] as! [Int64]
        return timeData
    }
}

extension Time {
    init(timeData: TimeData) {
        place = timeData.place
        startsection = Int(timeData.startsection)
        endsection = Int(timeData.endsection)
        week = Int(timeData.week)
        teachweek = timeData.teachweek.map() { Int($0) }
    }
}

extension Course {
    init(courseData: CourseData) {
        name = courseData.name
        teacher = courseData.teacher
        time = courseData.time?.map() { Time(timeData: $0) }
    }
}

class CourseManager: NSObject {
    private var context: NSManagedObjectContext!
    private var allCourseData: [TimeData]!
    
    override init() {
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")!
        let url = groupURL.appendingPathComponent("course.data")
        let bundle = Bundle(for: CourseManager.self)
        let model = NSManagedObjectModel.mergedModel(from: [bundle])!
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        self.context = context
        let request = TimeData.fetchAllRequest()
        let courses = try! context.fetch(request)
        if courses.count != 0 {
            allCourseData = courses
        } else {
            allCourseData = nil
        }
    }
    
    static func deleteCourse() {}
    
    func loadCoursesAsync(handler: (() -> Void)?) {
        let (studentNumber, teachPassword, portalPassword) = KeyInfo.shared.getAccount()!
        DispatchQueue.global().async {
            guard let courses = DUTInfo(studentNumber: studentNumber,
                                        teachPassword: teachPassword,
                                        portalPassword: portalPassword).courseInfo() else {
                return
            }
            let request = CourseData.fetchAllRequest()
            let coursesData = try! self.context.fetch(request)
            _ = courses.filter() { !(coursesData.map() { $0.name }).contains($0.name) }
                .map() { CourseData.insertNewObject(from: $0, into: self.context) }
            try! self.context.save()
            handler?()
        }
    }
    
    func isLoaded() -> Bool {
        return allCourseData != nil
    }
    
    func addCourse(_ courses: [[String: String]]) {}
    
    func importData(courses: [Course]) {
        _ = courses.map() { CourseData.insertNewObject(from: $0, into: context) }
        try! context.save()
        let request = TimeData.fetchAllRequest()
        let courses = try! context.fetch(request)
        if courses.count != 0 {
            allCourseData = courses
        } else {
            allCourseData = nil
        }
    }
    
    func importData(dics: [[String: Any]]) {
        _ = dics.map() { CourseData.importData(from: $0, into: context)}
        try! context.save()
        let request = TimeData.fetchAllRequest()
        let courses = try! context.fetch(request)
        if courses.count != 0 {
            allCourseData = courses
        } else {
            allCourseData = nil
        }
    }
    
    func exportCourse() -> [Course] {
        let request = CourseData.fetchAllRequest()
        let allCourseData = try! context.fetch(request)
        let courses = allCourseData.map() { Course(courseData: $0) }
        return courses
    }
    
    func exportDic() -> [[String: Any]] {
        let request = CourseData.fetchAllRequest()
        let allCourseData = try! context.fetch(request)
        let dics = allCourseData.map() { $0.export() }
        return dics
    }
    
    private func coursesAWeek(_ date: Date) -> (courses: [TimeData], teachweek: Int) {
        let teachweekDataFormatter = DateFormatter()
        teachweekDataFormatter.dateFormat = "w"
        let teachweek = Int(teachweekDataFormatter.string(from: date))! - 9
        guard let allCourseData = allCourseData else {
            return ([], teachweek)
        }
        let values = allCourseData.filter { time in
            guard time.startsection != 0 else {
                return false
            }
            return time.teachweek.contains(Int64(teachweek))
        }
        return (values, teachweek)
    }
    
    func coursesThisWeek(_ date: Date = Date()) -> (courses: [TimeData], teachweek: Int, date: Date) {
        let tuple = coursesAWeek(date)
        return (tuple.courses, tuple.teachweek, date)
    }
    
    func coursesNextWeek(_ date: Date = Date()) -> (courses: [TimeData], teachweek: Int, date: Date) {
        let nextDate = date.addingTimeInterval(7 * 60 * 60 * 24)
        let tuple = coursesAWeek(nextDate)
        return (tuple.courses, tuple.teachweek, nextDate)
    }
    
    func coursesLastWeek(_ date: Date = Date()) -> (courses: [TimeData], teachweek: Int, date: Date) {
        let lastDate = date.addingTimeInterval(-7 * 60 * 60 * 24)
        let tuple = coursesAWeek(lastDate)
        return (tuple.courses, tuple.teachweek, lastDate)
    }
    
    private func coursesADay(_ date: Date) -> (courses: [TimeData], teachweek: Int, week: Int) {
        let (courses, teachweek) = coursesAWeek(date)
        let weekFormatter = DateFormatter()
        weekFormatter.dateFormat = "e"
        let week = Int(weekFormatter.string(from: date))! - 1
        let coursesaday = courses.filter {
            $0.week == week
        }.sorted {
            $0.startsection <= $1.startsection
        }
        return (coursesaday, teachweek, week)
    }
    
    func coursesToday(_ date: Date = Date()) -> (courses: [TimeData], teachweek: Int, week: Int, date: Date) {
        let tuple = coursesADay(date)
        return (tuple.courses, tuple.teachweek, tuple.week, date)
    }
    
    func coursesNextDay(_ date: Date = Date()) -> (courses: [TimeData], teachweek: Int, week: Int, date: Date) {
        let nextDate = date.addingTimeInterval(60 * 60 * 24)
        let tuple = coursesADay(nextDate)
        return (tuple.courses, tuple.teachweek, tuple.week, nextDate)
    }
    
    func coursesLastDay(_ date: Date = Date()) -> (courses: [TimeData], teachweek: Int, week: Int, date: Date) {
        let lastDate = date.addingTimeInterval(-60 * 60 * 24)
        let tuple = coursesADay(lastDate)
        return (tuple.courses, tuple.teachweek, tuple.week, lastDate)
    }
    
    func courseNow(_ date: Date = Date()) -> (course: TimeData?, teachweek: Int, week: Int, date: Date) {
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
        var nowCourse: TimeData?
        for course in tuple.courses {
            let number = course.startsection
            if number >= coursenumber {
                nowCourse = course
                break
            }
        }
        return (nowCourse, tuple.teachweek, tuple.week, date)
    }
}
