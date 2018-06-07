//
//  TestData.swift
//  DUTInfomation
//
//  Created by shino on 2018/6/1.
//  Copyright © 2018 shino. All rights reserved.
//

import CoreData

class TestData: NSManagedObject, Codable{
    private static var context: NSManagedObjectContext!
    
    @NSManaged private(set) var name: String
    @NSManaged private(set) var date: Date
    @NSManaged private(set) var starttime: Date
    @NSManaged private(set) var endtime: Date
    @NSManaged private(set) var place: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case date
        case starttime
        case endtime
        case place
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try! container.encode(name, forKey: .name)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD"
        try! container.encode(dateFormatter.string(from: date), forKey: .date)
        dateFormatter.dateFormat = "hh:mm"
        try! container.encode(dateFormatter.string(from: starttime), forKey: .starttime)
        try! container.encode(dateFormatter.string(from: endtime), forKey: .endtime)
        try! container.encode(place, forKey: .place)
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init(entity: TestData.entity(), insertInto: TestData.context)
        let container = try! decoder.container(keyedBy: CodingKeys.self)
        name = try! container.decode(String.self, forKey: .name)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 8)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = try! container.decode(String.self, forKey: .date)
        date = dateFormatter.date(from: dateStr)!
        dateFormatter.dateFormat = "HH:mm"
        let starttimeStr = try! container.decode(String.self, forKey: .starttime)
        starttime = dateFormatter.date(from: starttimeStr)!
        let endtimeStr = try! container.decode(String.self, forKey: .endtime)
        endtime = dateFormatter.date(from: endtimeStr)!
        place = try! container.decode(String.self, forKey: .place)
    }
}

extension TestData: ManagedObject {
    static var viewContext: NSManagedObjectContext {
        get { return context }
        set { context = newValue }
    }
    
    static var entityName: String {
        return "TestData"
    }
    
    
}
