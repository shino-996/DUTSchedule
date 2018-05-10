//
//  TestInfo.swift
//  DUTInfomation
//
//  Created by shino on 18/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import Foundation
import DUTInfo

class TestInfo {
    private var fileURL: URL
    
    var tests: [[String: String]]? {
        return allTests
    }
    
    private var allTests: [[String: String]]? {
        didSet {
            if let tests = allTests {
                (tests as NSArray).write(to: self.fileURL, atomically: true)
            }
        }
    }
    
    init() {
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")
        fileURL = groupURL!.appendingPathComponent("test.plist")
        guard let array = NSArray(contentsOf: fileURL) as? [[String: String]] else {
            allTests = nil
            return
        }
        allTests = array
    }
    
    func loadTestAsync(_ handle: (() -> Void)?) {
        let (studentNumber, teachPassword, _) = KeyInfo.shared.getAccount()!
        DispatchQueue.global().async {
            let json = DUTInfo(studentNumber: studentNumber,
                                    password: teachPassword,
                                    fetches: [.test]).fetchInfo()
            struct Info: Decodable {
                let test: [Test]
                struct Test: Decodable {
                    let name: String
                    let teachweek: String
                    let date: String
                    let time: String
                    let place: String
                }
            }
            let decoder = JSONDecoder()
            _ = try! decoder.decode(Info.self, from: json.data(using: .utf8)!)
            self.allTests = nil
        }
    }
    
    private func sortTests(_ tests: [[String: String]]) -> [[String: String]] {
        var sortedTests = [[String: String]]()
        for test in tests {
            var sortedTest = [String: String]()
            let dateString = test["date"]!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            let date = dateFormatter.date(from: dateString)
            let weekFormatter = DateFormatter()
            weekFormatter.dateFormat = "e"
            let chineseWeek = ["日", "一", "二", "三", "四", "五", "六"]
            sortedTest["teachweek"] = test["teachweek"]! + "周周"
                                      + chineseWeek[Int(weekFormatter.string(from: date!))!]
            sortedTest["name"] = test["name"]!
            sortedTest["date"] = test["date"]!
            sortedTest["time"] = test["time"]!
            sortedTest["place"] = test["place"]!
            sortedTests.append(sortedTest)
        }
        return sortedTests.sorted { test_1, test_2 in
            let dateString_1 = test_1["date"]! + " "
                               + test_1["time"]!.components(separatedBy: "-").first!
            let dateString_2 = test_2["date"]! + " "
                               + test_2["time"]!.components(separatedBy: "-").first!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
            let date_1 = dateFormatter.date(from: dateString_1)!
            let date_2 = dateFormatter.date(from: dateString_2)!
            return date_1.compare(date_2) == .orderedAscending
        }
    }
    
    static func deleteTest() {
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")
        let fileURL = groupURL!.appendingPathComponent("test.plist")
        try! FileManager.default.removeItem(at: fileURL)
    }
}
