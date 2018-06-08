//
//  EcardData.swift
//  DUTInfomation
//
//  Created by shino on 2018/6/1.
//  Copyright © 2018 shino. All rights reserved.
//

import CoreData

class EcardData: NSManagedObject, Decodable {
    private static var context: NSManagedObjectContext!
    
    @NSManaged private(set) var ecard: Double
    
    enum CodingKeys: String, CodingKey {
        case cardbal
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init(entity: EcardData.entity(), insertInto: EcardData.context)
        let container = try! decoder.container(keyedBy: CodingKeys.self)
        let ecardStr = try! container.decode(String.self, forKey: .cardbal)
        ecard = Double(ecardStr)!
    }
}

extension EcardData: ManagedObject {
    static var viewContext: NSManagedObjectContext {
        get { return context }
        set { context = newValue }
    }
    
    static var entityName: String {
        return "EcardData"
    }
}

extension EcardData {
    func ecardStr() -> String {
        return "\(ecard)元"
    }
}
