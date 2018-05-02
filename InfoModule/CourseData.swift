//
//  CourseData.swift
//  DUTInfomation
//
//  Created by shino on 2018/4/24.
//  Copyright © 2018 shino. All rights reserved.
//

import CoreData

// 上课地点等信息与谭程信息分开建表, 建立多对一关系, 便于分开查询
// 因为 Codable 目前无法放在扩展中实现, 只能放在类定义中实现

typealias JSON = String

final class CourseData: NSManagedObject, Codable {
    fileprivate static var context: NSManagedObjectContext!
    
    @NSManaged var name: String
    @NSManaged var teacher: String
    @NSManaged var time: Set<TimeData>?
    
    enum CodingKeys: String, CodingKey {
        case name
        case teacher
        case time
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try! container.encode(name, forKey: .name)
        try! container.encode(teacher, forKey: .teacher)
        if let time = time {
            let timeArray = Array(time)
            try! container.encode(timeArray, forKey: .time)
        }
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init(entity: CourseData.entity(), insertInto: CourseData.context)
        let container = try! decoder.container(keyedBy: CodingKeys.self)
        name = try! container.decode(String.self, forKey: .name)
        teacher = try! container.decode(String.self, forKey: .teacher)
        TimeData.context = CourseData.context
        if let timeArray = try? container.decode([TimeData].self, forKey: .time) {
            _ = timeArray.map { $0.course = self }
        }
    }
}

extension CourseData: ManagedObject {
    static var viewContext: NSManagedObjectContext {
        get { return context }
        set { context = newValue }
    }
    
    static var entityName: String {
        return "CourseData"
    }
}

final class TimeData: NSManagedObject, Codable {
    fileprivate static var context: NSManagedObjectContext!
    
    @NSManaged var place: String
    @NSManaged var startsection: Int64
    @NSManaged var endsection: Int64
    @NSManaged var week: Int64
    @NSManaged var teachweek: [Int64]
    @NSManaged var course: CourseData
    
    enum CodingKeys: String, CodingKey {
        case place
        case startsection
        case endsection
        case week
        case teachweek
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try! container.encode(place, forKey: .place)
        try! container.encode(startsection, forKey: .startsection)
        try! container.encode(endsection, forKey: .endsection)
        try! container.encode(week, forKey: .week)
        try! container.encode(teachweek, forKey: .teachweek)
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init(entity: TimeData.entity(), insertInto: TimeData.context)
        let container = try! decoder.container(keyedBy: CodingKeys.self)
        place = try! container.decode(String.self, forKey: .place)
        startsection = try! container.decode(Int64.self, forKey: .startsection)
        endsection = try! container.decode(Int64.self, forKey: .endsection)
        week = try! container.decode(Int64.self, forKey: .week)
        teachweek = try! container.decode([Int64].self, forKey: .teachweek)
    }
}

extension TimeData: ManagedObject {
    static var viewContext: NSManagedObjectContext {
        get { return context }
        set { context = newValue }
    }
    
    static var entityName: String {
        return "TimeData"
    }
}
