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

final class CourseData: NSManagedObject, Decodable {
    private static var context: NSManagedObjectContext!
    
    @NSManaged private(set) var name: String
    @NSManaged private(set) var teacher: String
    @NSManaged private(set) var time: NSOrderedSet?
    
    enum CodingKeys: String, CodingKey {
        case name
        case teacher
        case time
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init(entity: CourseData.entity(), insertInto: CourseData.context)
        let container = try! decoder.container(keyedBy: CodingKeys.self)
        name = try! container.decode(String.self, forKey: .name)
        teacher = try! container.decode(String.self, forKey: .teacher)
        TimeData.viewContext = CourseData.context
        if let timeArray = try? container.decode([TimeData].self, forKey: .time) {
            let sortedArray = timeArray.sorted {
                if $0.weekday == $1.weekday {
                    return $0.startsection <= $1.startsection
                } else {
                    return $0.weekday < $1.weekday
                }
            }
            time = NSOrderedSet(array: sortedArray)
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
