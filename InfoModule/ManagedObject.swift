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

extension ManagedObject where Self: Codable {
    static func fetchAllRequest() -> NSFetchRequest<Self> {
        let request =  NSFetchRequest<Self>(entityName: entityName)
        request.returnsObjectsAsFaults = false
        return request
    }
    
    static func fetchAllIDRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.resultType = .managedObjectIDResultType
        return request
    }
    
    static func insertNewObject(from json: String, into context: NSManagedObjectContext) -> Self {
        let decoder = JSONDecoder()
        let jsonData = json.data(using: .utf8)!
        Self.viewContext = context
        let newObject = try! decoder.decode(Self.self, from: jsonData)
        return newObject
    }
    
    static func insertNewObject(into context: NSManagedObjectContext) -> Self {
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! Self
    }
    
    func exportJson() -> JSON {
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(self)
        let json = String(data: jsonData, encoding: .utf8)!
        return json
    }
}
