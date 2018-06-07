//
//  CourseInfo.swift
//  DUTInformationToday
//
//  Created by shino on 2017/9/27.
//  Copyright © 2017年 shino. All rights reserved.
//

import CoreData

class DataManager: NSObject {
    private var context: NSManagedObjectContext!
    
    override init() {
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")!
        let url = groupURL.appendingPathComponent("dutinfo.data")
        let bundle = Bundle(for: DataManager.self)
        let model = NSManagedObjectModel.mergedModel(from: [bundle])!
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        self.context = context
    }
    
//    func deleteAllCourse() {
//        let deleteRequest = NSBatchDeleteRequest(objectIDs: allCourseData.map { $0.objectID })
//        if let persistentCoordinator = context.persistentStoreCoordinator {
//            try! persistentCoordinator.execute(deleteRequest, with: context)
//        }
//        allCourseData = nil
//    }
    
    func load(_ type: [FetchType]) {
        guard let info = NetRequest.shared.fetchInfo(type) else {
            return
        }
        let encoder = JSONEncoder()
        _ = type.map {
            var notificationName: String
            switch $0 {
            case .course:
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: CourseData.fetchAllIDRequest())
                try! context.persistentStoreCoordinator!.execute(deleteRequest, with: context)
                let courses = info.course!
                _ = courses.map {
                    CourseData.insertNewObject(from: String(data: (try! encoder.encode($0)), encoding: .utf8)!,
                                               into: context)
                }
                notificationName = "space.shino.post.course"
            case .test:
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: TestData.fetchAllIDRequest())
                try! context.persistentStoreCoordinator!.execute(deleteRequest, with: context)
                let tests = info.test!
                _ = tests.map {
                    TestData.insertNewObject(from: String(data: (try! encoder.encode($0)), encoding: .utf8)!,
                                             into: context)
                }
                notificationName = "space.shino.post.test"
            case .net:
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: NetData.fetchAllIDRequest())
                try! context.persistentStoreCoordinator!.execute(deleteRequest, with: context)
                let net = info.net!
                _ = NetData.insertNewObject(from: String(data: (try! encoder.encode(net)), encoding: .utf8)!,
                                            into: context)
                notificationName = "space.shino.post.net"
            case .ecard:
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: EcardData.fetchAllIDRequest())
                try! context.persistentStoreCoordinator!.execute(deleteRequest, with: context)
                let ecard = info.ecard!
                _ = EcardData.insertNewObject(from: String(data: (try! encoder.encode(ecard)), encoding: .utf8)!,
                                              into: context)
                notificationName = "space.shino.post.ecard"
            }
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: notificationName)))
        }
        try! context.save()
    }
    
    enum CourseTimeRequestType {
        case thisWeek(Date)
        case nextWeek(Date)
        case lastWeek(Date)
        case today(Date)
        case nextDay(Date)
        case lastDay(Date)
        case now(Date)
    }
    
    func courses(of type: CourseTimeRequestType) -> [TimeData] {
        var request: NSFetchRequest<TimeData>
        switch type {
        case .thisWeek(let date):
            request = TimeData.fetchRequest(for: .week(date))
        case .nextWeek(let date):
            request = TimeData.fetchRequest(for: .week(date.nextWeek()))
        case .lastWeek(let date):
            request = TimeData.fetchRequest(for: .week(date.lastWeek()))
        case .today(let date):
            request = TimeData.fetchRequest(for: .day(date))
        case .nextDay(let date):
            request = TimeData.fetchRequest(for: .day(date.nextDate()))
        case .lastDay(let date):
            request = TimeData.fetchRequest(for: .day(date.lastDate()))
        case .now(let date):
            request = TimeData.fetchRequest(for: .now(date))
        }
        return try! context.fetch(request)
    }
    
    func tests() -> [TestData] {
        let request = TestData.fetchAllRequest()
        return try! context.fetch(request)
    }
    
    func net() -> NetData {
        let request = NetData.fetchAllRequest()
        request.fetchLimit = 1
        return try! context.fetch(request).first!
    }
    
    func ecard() -> EcardData {
        let request = EcardData.fetchAllRequest()
        request.fetchLimit = 1
        return try! context.fetch(request).first!
    }
}
