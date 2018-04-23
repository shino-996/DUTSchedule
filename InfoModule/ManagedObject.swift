//
//  ManagedObject.swift
//  DUTInfomation
//
//  Created by shino on 2018/4/23.
//  Copyright © 2018 shino. All rights reserved.
//

import CoreData

protocol ManagedObject where Self: NSManagedObject {
    associatedtype Object
    
    static var entityName: String { get }
    static func fetchAllRequest() -> NSFetchRequest<Self>
    static func insertNewObject(into: NSManagedObjectContext) -> Self
    static func insertNewObject(from: Object, into: NSManagedObjectContext) -> Self
    static func importData(from: [String: Any], into: NSManagedObjectContext) -> Self
    func export() -> [String: Any]
}

extension ManagedObject {
    static var entityName: String {
        return Self.entity().name!
    }
    
    static func fetchAllRequest() -> NSFetchRequest<Self> {
        return NSFetchRequest(entityName: Self.entityName)
    }
    
    static func insertNewObject(into context: NSManagedObjectContext) -> Self {
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! Self
    }
}
