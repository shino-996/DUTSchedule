//
//  CacheInfo.swift
//  DUTInfomation
//
//  Created by shino on 20/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import Foundation
import DUTInfo

class CacheInfo: NSObject {
    private var fileURL: URL
    private var cache: NSMutableDictionary?
    
    private var netCost: Double {
        didSet {
            cache?["netcost"] = netCost
            cache?.write(to: fileURL, atomically: true)
        }
    }
    
    var netInfo: (cost: String, flow: String) {
        get {
            let cost = "\(netCost)元"
            var flow: String
            if abs(netFlow) > 1024 {
                flow = String(format: "%.1lfGB", netFlow / 1024)
            } else {
                flow = "\(netFlow)MB"
            }
            return (cost, flow)
        }
    }
    
    private var netFlow: Double {
        didSet {
            cache?["netflow"] = netFlow
        }
    }
    
    var ecard: String {
        return "\(ecardCost)元"
    }
    
    private var ecardCost: Double {
        didSet {
            cache?["ecardcost"] = ecardCost
        }
    }
    
    var name: String {
        return personName
    }
    
    private var personName: String {
        didSet {
            cache?["personname"] = personName
        }
    }
    
    override init() {
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")!
        fileURL = groupURL.appendingPathComponent("cache.plist")
        cache = NSMutableDictionary(contentsOf: fileURL)
        if cache == nil {
            cache = NSMutableDictionary()
        }
        let dictionary = cache as? [String: Any]
        netCost = (dictionary?["netcost"] as? Double) ?? 0
        netFlow = (dictionary?["netflow"] as? Double) ?? 0
        ecardCost = (dictionary?["ecardcost"] as? Double) ?? 0
        personName = (dictionary?["personname"] as? String) ?? ""
    }
    
    func loadCacheAsync(_ handler: (() -> Void)?) {
        let (studentNumber, teachPassword, portalPassword) = KeyInfo.shared.getAccount()!
        DispatchQueue.global().async {
            let dutInfo = DUTInfo(studentNumber: studentNumber,
                                  teachPassword: teachPassword,
                                  portalPassword: portalPassword)
            if let net = dutInfo.netInfo() {
                (self.netCost, self.netFlow) = net
            }
            if let ecard = dutInfo.moneyInfo() {
                self.ecardCost = ecard
            }
            if let name = dutInfo.personInfo() {
                self.personName = name
            }
            self.cache?.write(to: self.fileURL, atomically: true)
            handler?()
        }
    }
    
    func shouldRefresh() -> Bool {
        let date = Date()
        let nowDate = date.timeIntervalSince1970
        let lastDate = Double(cache?["refreshdate"] as? String ?? "") ?? 0
        if nowDate - lastDate > 60 {
            cache?["refreshdate"] = String(nowDate)
            cache?.write(to: fileURL, atomically: true)
            return true
        } else {
            return false
        }
    }
    
    static func deleteCache() {
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")
        let fileURL = groupURL!.appendingPathComponent("cache.plist")
        try! FileManager.default.removeItem(at: fileURL)
    }
}
