//
//  ManagedObject.swift
//  DUTInfomation
//
//  Created by shino on 2018/4/23.
//  Copyright © 2018 shino. All rights reserved.
//

import CoreData

protocol ManagedObject where Self: NSManagedObject {
    static var entityName: String { get }
    static func insertNewObject(into: NSManagedObjectContext) -> Self
    static func insertNewObject(from json: String, into context: NSManagedObjectContext) -> Self
    func exportJson() -> String
}

extension ManagedObject {
    static func fetchAllRequest() -> NSFetchRequest<Self> {
        return NSFetchRequest(entityName: entityName)
    }
    
    static func insertNewObject(into context: NSManagedObjectContext) -> Self {
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! Self
    }
}
