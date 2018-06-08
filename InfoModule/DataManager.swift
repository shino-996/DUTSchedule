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
        try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                            configurationName: nil,
                                            at: url,
                                            options: nil)
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        self.context = context
    }
    
    func backupFile() -> URL {
        return context.persistentStoreCoordinator!.backupFile()
    }
    
    func deleteAll() {
        CourseData.deleteAll(from: context)
        TestData.deleteAll(from: context)
        NetData.deleteAll(from: context)
        EcardData.deleteAll(from: context)
        UserInfo.shared.removeAccount()
    }
    
    func load(_ type: [LoadType]) {
        let notificationCenter = NotificationCenter.default
        guard let info = NetRequest.shared.fetchInfo(type) else {
            notificationCenter.post(name: "space.shino.post.finishfetch")
            return
        }
        let encoder = JSONEncoder()
        for eachType in type {
            switch eachType {
            case .course:
                CourseData.deleteAll(from: context)
                let courses = info.course!
                for course in courses {
                    let jsonData = try! encoder.encode(course)
                    CourseData.insertNewObject(from: jsonData, into: context)
                }
                notificationCenter.post(name: "space.shino.post.course")
            case .test:
                TestData.deleteAll(from: context)
                let tests = info.test!
                for test in tests {
                    let jsonData = try! encoder.encode(test)
                    TestData.insertNewObject(from: jsonData, into: context)
                }
                notificationCenter.post(name: "space.shino.post.test")
            case .net:
                NetData.deleteAll(from: context)
                let net = info.net!
                let jsonData = try! encoder.encode(net)
                NetData.insertNewObject(from: jsonData, into: context)
                notificationCenter.post(name: "space.shino.post.net")
            case .ecard:
                EcardData.deleteAll(from: context)
                let ecard = info.ecard!
                let jsonData = try! encoder.encode(ecard)
                EcardData.insertNewObject(from: jsonData, into: context)
                notificationCenter.post(name: "space.shino.post.ecard")
            }
        }
        do {
            try context.save()
        } catch(let error) {
            print(error)
            context.rollback()
        }
        notificationCenter.post(name: "space.shino.post.finishfetch")
    }
    
    enum CourseTimeRequestType {
        case thisWeek(Date)
        case nextWeek(Date)
        case lastWeek(Date)
        case today(Date)
        case nextDay(Date)
        case lastDay(Date)
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
        }
        return try! context.fetch(request)
    }
    
    func tests() -> [TestData] {
        let request = TestData.fetchAllRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true),
                                   NSSortDescriptor(key: "starttime", ascending: true)]
        return try! context.fetch(request)
    }
    
    func net() -> NetData? {
        let request = NetData.fetchAllRequest()
        request.fetchLimit = 1
        return try! context.fetch(request).first
    }
    
    func ecard() -> EcardData? {
        let request = EcardData.fetchAllRequest()
        request.fetchLimit = 1
        return try! context.fetch(request).first
    }
}
