//
//  TestInfo.swift
//  DUTInfomation
//
//  Created by shino on 18/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import Foundation

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
                "fetch": ["test"]
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
            let info = try! decoder.decode(Info.self, from: json.data(using: .utf8)!)
            self.allTests = info.test.map {
                return ["name": $0.name,
                         "teachweek": $0.teachweek,
                         "date": $0.date,
                         "time": $0.time,
                         "place": $0.place]
            }
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
