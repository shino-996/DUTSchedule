//
//  NetData.swift
//  DUTInfomation
//
//  Created by shino on 2018/6/1.
//  Copyright © 2018 shino. All rights reserved.
//

import CoreData


class NetData: NSManagedObject, Codable {
    private static var context: NSManagedObjectContext!
    
    @NSManaged private(set) var cost: Double
    @NSManaged private(set) var flow: Double
    
    enum CodingKeys: String, CodingKey {
        case fee
        case usedTraffic
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try! container.encode("\(cost)", forKey: .fee)
        try! container.encode("\(flow)", forKey: .usedTraffic)
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init(entity: NetData.entity(), insertInto: NetData.context)
        let container = try! decoder.container(keyedBy: CodingKeys.self)
        let costStr = try! container.decode(String.self, forKey: .fee)
        cost = Double(costStr)!
        let flowStr = try! container.decode(String.self, forKey: .usedTraffic)
        flow = Double(flowStr)!
    }
}

extension NetData: ManagedObject {
    static var viewContext: NSManagedObjectContext {
        get { return context }
        set { context = newValue }
    }
    
    static var entityName: String {
        return "NetData"
    }
}
