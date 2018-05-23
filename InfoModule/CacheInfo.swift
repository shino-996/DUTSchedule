//
//  CacheInfo.swift
//  DUTInfomation
//
//  Created by shino on 20/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import Foundation

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
        let (studentNumber, password) = KeyInfo.shared.getAccount()!
        DispatchQueue.global().async {
            let url = URL(string: "https://t.warshiprpg.xyz:88/dut")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = """
            {
                "studentnumber": "\(studentNumber)",
                "password": "\(password)",
                "fetch": ["net", "ecard", "person"]
            }
            """.data(using: .utf8)
            let semaphore = DispatchSemaphore(value: 0)
            var json: JSON!
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print(error)
                    return
                }
                json = String(data: data!, encoding: .utf8)
                semaphore.signal()
            }.resume()
            _ = semaphore.wait(timeout: .distantFuture)
            struct Info: Decodable {
                let ecard: Ecard
                let person: String
                let net: Net
                
                struct Net: Decodable {
                    let fee: String
                    let usedTraffic: String
                }
                struct Ecard: Decodable {
                    let cardbal: String
                }
            }
            let decoder = JSONDecoder()
            let info = try! decoder.decode(Info.self, from: json.data(using: .utf8)!)
            self.netCost = Double(info.net.fee)!
            self.netFlow = 30720 - Double(info.net.usedTraffic)!
            self.ecardCost = Double(info.ecard.cardbal)!
            self.personName = info.person
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
