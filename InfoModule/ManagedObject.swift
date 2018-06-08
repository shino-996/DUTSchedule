//
//  ManagedObject.swift
//  DUTInfomation
//
//  Created by shino on 2018/4/23.
//  Copyright © 2018 shino. All rights reserved.
//

import CoreData

protocol ManagedObject where Self: NSManagedObject {
    static var viewContext: NSManagedObjectContext { get set }
    
    static var entityName: String { get }
}

extension ManagedObject where Self: Decodable {
    static func fetchAllRequest() -> NSFetchRequest<Self> {
        let request =  NSFetchRequest<Self>(entityName: entityName)
        request.returnsObjectsAsFaults = false
        return request
    }
    
    static func deleteAll(from context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.resultType = .managedObjectIDResultType
        request.includesPropertyValues = false
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.persistentStoreCoordinator!.execute(deleteRequest, with: context)
        } catch(let error) {
            print(error)
        }
    }
    
    static func insertNewObject(from jsonData: Data, into context: NSManagedObjectContext) {
        let decoder = JSONDecoder()
        Self.viewContext = context
        _ = try! decoder.decode(Self.self, from: jsonData)
    }
    
    static func insertNewObject(into context: NSManagedObjectContext) -> Self {
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! Self
    }
}
