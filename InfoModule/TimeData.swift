//
//  TimeData.swift
//  DUTInfomation
//
//  Created by shino on 2018/5/31.
//  Copyright © 2018 shino. All rights reserved.
//

import CoreData

final class TimeData: NSManagedObject, Decodable {
    private static var context: NSManagedObjectContext!
    
    @NSManaged private(set) var place: String
    @NSManaged private(set) var startsection: Int16
    @NSManaged private(set) var endsection: Int16
    @NSManaged private(set) var weekday: Int16
    @NSManaged private(set) var startweek: Int16
    @NSManaged private(set) var endweek: Int16
    @NSManaged private(set) var course: CourseData
    
    enum CodingKeys: String, CodingKey {
        case place
        case startsection
        case endsection
        case startweek
        case endweek
        case weekday
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init(entity: TimeData.entity(), insertInto: TimeData.context)
        let container = try! decoder.container(keyedBy: CodingKeys.self)
        place = try! container.decode(String.self, forKey: .place)
        startsection = try! container.decode(Int16.self, forKey: .startsection)
        endsection = try! container.decode(Int16.self, forKey: .endsection)
        startweek = try! container.decode(Int16.self, forKey: .startweek)
        endweek = try! container.decode(Int16.self, forKey: .endweek)
        weekday = try! container.decode(Int16.self, forKey: .weekday)
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

extension TimeData {
    enum FetchType {
        case week(Date)
        case day(Date)
        case now(Date)
    }
    
    static func fetchRequest(for type: FetchType) -> NSFetchRequest<TimeData> {
        let request = NSFetchRequest<TimeData>(entityName: entityName)
        var predicate: NSPredicate
        switch type {
        case .week(let date):
            predicate = NSPredicate(format: "%d between { startweek, endweek }",
                                    date.teachweek())
        case .day(let date):
            predicate = NSPredicate(format: "%d between { startweek, endweek } and weekday == %d",
                                    date.teachweek(),
                                    date.weekday())
        case .now(let date):
            predicate = NSPredicate(format: "%d between { startweek, endweek } and weekday == %d",
                                    date.teachweek(),
                                    date.weekday())
        }
        request.predicate = predicate
        return request
    }
}

