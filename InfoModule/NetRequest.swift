//
//  NetRequest.swift
//  DUTInfomation
//
//  Created by shino on 2018/6/1.
//  Copyright © 2018 shino. All rights reserved.
//

import CoreData

enum FetchType: String {
    case net
    case ecard
    case course
    case test
}

struct NetRequest {
    static let shared = NetRequest()
    
    private init() {}
    
    func auth(studentNumber: String, password: String) -> Bool {
        return true
    }
    
//    func fetchInfo(_ type: [FetchType]) -> JsonDataType? {
//        let json = """
//        {
//            "net":
//            {
//                "fee": 3.45,
//                "flag": "success",
//                "account": "学号就不显示了",
//                "usedTraffic": 11851.52
//            },
//            "person": "王梓浓",
//            "library":
//            {
//                "hastime": true,
//                "opentime": "7:50",
//                "closetime": "21:30"
//            },
//            "course": [
//            {
//                "name": "嵌入式系统设计",
//                "teacher": "丁男 董校",
//                "time": [
//                {
//                    "place": "综合教学2号楼",
//                    "startsection": 1,
//                    "endsection": 2,
//                    "weekday": 4,
//                    "startweek": 1,
//                    "endweek": 16
//                },
//                {
//                    "place": "综合教学2号楼",
//                    "startsection": 5,
//                    "endsection": 6,
//                    "weekday": 1,
//                    "startweek": 1,
//                    "endweek": 16
//                }]
//            }],
//            "test":[
//            {
//                "name": "嵌入式系统设计-01 ",
//                "teachweek": "8",
//                "date": "2018-04-26",
//                "starttime": "08:00",
//                "endtime": "09:40",
//                "place": "第一教学馆1-209"
//            }],
//            "ecard":
//            {
//                "flag": "success",
//                "cardbal": 81.58,
//                "paybal": 0.00
//            }
//        }
//        """.data(using: .utf8)
//        let decoder = JSONDecoder()
//        return try! decoder.decode(JsonDataType.self, from: json!)
//    }
    
    func fetchInfo(_ type: [FetchType]) -> JsonDataType? {
        let (studentNumber, password) = UserInfo.shared.getAccount()!
        let url = URL(string: "https://t.warshiprpg.xyz:88/dut")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let str = type.reduce("") { $0 + "\"" + $1.rawValue + "\", " }
        let fetchString = str[str.startIndex ... str.index(str.endIndex, offsetBy: -3)]
        request.httpBody = """
        {
            "studentnumber": "\(studentNumber)",
            "password": "\(password)",
            "fetch": [\(fetchString)]
        }
        """.data(using: .utf8)
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        let semaphore = DispatchSemaphore(value: 0)
        var info: JsonDataType? = nil
        DispatchQueue.global().async {
            session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print(error)
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    fatalError("Http response format error")
                }
                if response.statusCode != 200 {
                    return
                }
                let decoder = JSONDecoder()
                info = try! decoder.decode(JsonDataType.self, from: data!)
                semaphore.signal()
            }.resume()
        }
        _ = semaphore.wait(timeout: .distantFuture)
        return info
    }
}
