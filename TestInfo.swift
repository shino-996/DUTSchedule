//
//  TestInfo.swift
//  DUTInfomation
//
//  Created by shino on 18/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import Foundation

struct TestInfo {
    var allTests: [[String: String]]? {
        didSet {
            guard let tests = allTests else {
                return
            }
            let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")
            let fileURL = groupURL!.appendingPathComponent("test.plist")
            allTests = sortTests(tests)
            (allTests! as NSArray).write(to: fileURL, atomically: true)
        }
    }
    
    init() {
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")
        let fileURL = groupURL!.appendingPathComponent("test.plist")
        guard let array = NSArray(contentsOf: fileURL) else {
            allTests = nil
            return
        }
        allTests = (array as! [[String: String]])
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
}
