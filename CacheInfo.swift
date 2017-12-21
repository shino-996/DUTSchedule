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
    
    var netCost: String {
        didSet {
            fileDictionary?["netcost"] = netCost
            fileDictionary?.write(to: fileURL, atomically: true)
            netCostHandle?()
        }
    }
    
    var netFlow: String {
        didSet {
            fileDictionary?["netflow"] = netFlow
            fileDictionary?.write(to: fileURL, atomically: true)
            self.netFlowHandle?()
        }
    }
    
    var ecardCost: String {
        didSet {
            fileDictionary?["ecardcost"] = ecardCost
            fileDictionary?.write(to: fileURL, atomically: true)
            ecardCostHandle?()
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
        let dictionary = fileDictionary as? [String: String]
        netCost = dictionary?["netcost"] ?? ""
        netFlow = dictionary?["netflow"] ?? ""
        ecardCost = dictionary?["ecardcost"] ?? ""
        personName = dictionary?["personname"] ?? ""
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
}
