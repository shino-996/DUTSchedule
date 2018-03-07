//
//  CacheInfo.swift
//  DUTInfomation
//
//  Created by shino on 20/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import Foundation

struct CacheInfo {
    private var fileURL: URL
    private var fileDictionary: NSMutableDictionary?
    
    var netCostHandle: ((String) -> Void)?
    var netFlowHandle: ((String) -> Void)?
    var ecardCostHandle: ((String) -> Void)?
    var personNameHandle: ((String) -> Void)?
    
    var netCost: Double {
        didSet {
            fileDictionary?["netcost"] = netCost
            fileDictionary?.write(to: fileURL, atomically: true)
            netCostHandle?(netCostText)
        }
    }
    var netCostText: String {
        get {
            return "\(netCost)元"
        }
    }
    
    var netFlow: Double {
        didSet {
            fileDictionary?["netflow"] = netFlow
            fileDictionary?.write(to: fileURL, atomically: true)
            self.netFlowHandle?(netFlowText)
        }
    }
    var netFlowText: String {
        get {
            if netFlow > 1024 {
                return String(format: "%.1lfGB", netFlow / 1024)
            } else {
                return "\(netFlow)MB"
            }
        }
    }
    
    var ecardCost: Double {
        didSet {
            fileDictionary?["ecardcost"] = ecardCost
            fileDictionary?.write(to: fileURL, atomically: true)
            ecardCostHandle?(ecardText)
        }
    }
    var ecardText: String {
        get {
            return "\(ecardCost)元"
        }
    }
    
    var personName: String {
        didSet {
            fileDictionary?["personname"] = personName
            fileDictionary?.write(to: fileURL, atomically: true)
            personNameHandle?(personName)
        }
    }
    
    init() {
        netCostHandle = nil
        netFlowHandle = nil
        ecardCostHandle = nil
        personNameHandle = nil
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")!
        fileURL = groupURL.appendingPathComponent("cache.plist")
        fileDictionary = NSMutableDictionary(contentsOf: fileURL)
        if fileDictionary == nil {
            fileDictionary = NSMutableDictionary()
        }
        let dictionary = fileDictionary as? [String: Any]
        netCost = (dictionary?["netcost"] as? Double) ?? 0
        netFlow = (dictionary?["netflow"] as? Double) ?? 0
        ecardCost = (dictionary?["ecardcost"] as? Double) ?? 0
        personName = (dictionary?["personname"] as? String) ?? ""
    }
    
    func shouldRefresh() -> Bool {
        netCostHandle?(netCostText)
        netFlowHandle?(netFlowText)
        ecardCostHandle?(ecardText)
        personNameHandle?(personName)
        let date = Date()
        let nowDate = date.timeIntervalSince1970
        let dictionary = fileDictionary as? [String: String]
        let lastDate = Double(dictionary?["refreshdate"] ?? "") ?? 0
        if nowDate - lastDate > 60 {
            fileDictionary?["refreshdate"] = String(nowDate)
            fileDictionary?.write(to: fileURL, atomically: true)
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
