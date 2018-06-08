//
//  NetData.swift
//  DUTInfomation
//
//  Created by shino on 2018/6/1.
//  Copyright © 2018 shino. All rights reserved.
//

import CoreData


class NetData: NSManagedObject, Decodable {
    private static var context: NSManagedObjectContext!
    
    @NSManaged private(set) var cost: Double
    @NSManaged private(set) var flow: Double
    
    enum CodingKeys: String, CodingKey {
        case fee
        case usedTraffic
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

extension NetData {
    func flowStr() -> String {
        if abs(30720 - flow) > 1024 {
            return String(format: "%.2lfG", (30720 - flow) / 1024)
        } else {
            return String(format: "%.2lfM", 30720 - flow)
        }
    }
    
    func costStr() -> String {
        return String(format: "%.2lf元", cost)
    }
}
