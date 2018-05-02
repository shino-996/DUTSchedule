//
//  CourseInfo.swift
//  DUTInformationToday
//
//  Created by shino on 2017/9/27.
//  Copyright © 2017年 shino. All rights reserved.
//

import DUTInfo
import CoreData

// 将网络获取的数据转换为 json
extension Course {
    func exportJson() -> JSON {
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(self)
        let json = String(data: jsonData, encoding: .utf8)!
        return json
    }
}

class CourseManager: NSObject {
    private var context: NSManagedObjectContext!
    private var allCourseData: [TimeData]!
    
    var isLoaded: Bool {
        return allCourseData != nil
    }
    
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
    
    func deleteAllCourse() {
        let deleteRequest = NSBatchDeleteRequest(objectIDs: allCourseData.map { $0.objectID })
        if let persistentCoordinator = context.persistentStoreCoordinator {
            try! persistentCoordinator.execute(deleteRequest, with: context)
        }
        allCourseData = nil
    }
    
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
            _ = courses.filter { !(coursesData.map { $0.name }).contains($0.name) }
                .map { CourseData.insertNewObject(from: $0.exportJson(), into: self.context) }
            try! self.context.save()
            let timeRequest = TimeData.fetchAllRequest()
            self.allCourseData = try! self.context.fetch(timeRequest)
            handler?()
        }
    }
    
    func importData(from jsonArray: [JSON]) {
        _ = jsonArray.map() { CourseData.insertNewObject(from: $0, into: context)}
        try! context.save()
        let request = TimeData.fetchAllRequest()
        let courses = try! context.fetch(request)
        if courses.count != 0 {
            allCourseData = courses
        } else {
            allCourseData = nil
        }
    }
    
    func exportJsonArray() -> [JSON] {
        let request = CourseData.fetchAllRequest()
        let allCourseData = try! context.fetch(request)
        let array = allCourseData.map() { $0.exportJson() }
        return array
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
