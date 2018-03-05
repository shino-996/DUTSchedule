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
    
    var netCostHandle: (() -> Void)? {
        didSet {
            netCostHandle?()
        }
    }
    var netFlowHandle: (() -> Void)? {
        didSet {
            netFlowHandle?()
        }
    }
    var ecardCostHandle: (() -> Void)? {
        didSet {
            ecardCostHandle?()
        }
    }
    var personNameHandle: (() -> Void)? {
        didSet {
            personNameHandle?()
        }
    }
    
    var netCost: Double {
        didSet {
            fileDictionary?["netcost"] = netCostText
            fileDictionary?.write(to: fileURL, atomically: true)
            netCostHandle?()
        }
    }
    
    var netCostText: String {
        get {
            return "\(netCost)元"
        }
    }
    
    var netFlow: Double {
        didSet {
            fileDictionary?["netflow"] = netFlowText
            fileDictionary?.write(to: fileURL, atomically: true)
            self.netFlowHandle?()
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
            fileDictionary?["ecardcost"] = ecardText
            fileDictionary?.write(to: fileURL, atomically: true)
            ecardCostHandle?()
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
            personNameHandle?()
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
