//
//  NetRequest.swift
//  DUTInfomation
//
//  Created by shino on 2018/6/1.
//  Copyright © 2018 shino. All rights reserved.
//

import CoreData
import AwaitKit
import PromiseKit

struct NetRequest {
    static let shared = NetRequest()
    
    private init() {}
    
    func auth(studentNumber: String, password: String) -> String? {
        return fetchInfo([.person])?.person
    }
    
    private func fetch(_ type: [LoadType]) -> Promise<(data: Data, response: URLResponse)> {
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
        return session.dataTask(.promise, with: request)
    }
    
    func fetchInfo(_ type: [LoadType]) -> JsonDataType? {
        do {
            let (data, response) = try await(fetch(type))
            if (response as? HTTPURLResponse)?.statusCode ?? 0 != 200 {
                return nil
            }
            let decoder = JSONDecoder()
            let info = try decoder.decode(JsonDataType.self, from: data)
            return info
        } catch(let error) {
            print(error)
            return nil
        }
    }
/*
    func fetchInfo(_ type: [LoadType]) -> JsonDataType? {
        do {
            let data = """
            {
                "course": [
                {
                    "name": "计算机系统结构",
                    "teacher": "王宇新",
                    "time": [
                    {
                        "place": "综合教学2号楼",
                        "startsection": 5,
                        "endsection": 6,
                        "weekday": 1,
                        "startweek": 1,
                        "endweek": 8
                    },
                    {
                        "place": "综合教学2号楼",
                        "startsection": 1,
                        "endsection": 2,
                        "weekday": 4,
                        "startweek": 1,
                        "endweek": 8
                    }]
                }],
                "test": [
                {
                    "name": "假装有补考-01 ",
                    "date": "2018-08-31",
                    "starttime": "08:00",
                    "endtime": "09:40",
                    "place": "第一教学馆1-209"
                },
                {
                    "name": "假装有补考-02 ",
                    "date": "2018-09-1",
                    "starttime": "08:00",
                    "endtime": "09:40",
                    "place": "第一教学馆1-209"
                },
                {
                    "name": "假装有补考-03 ",
                    "date": "2018-09-1",
                    "starttime": "13:30",
                    "endtime": "15:10",
                    "place": "第一教学馆1-209"
                }],
                "net":
                {
                    "fee": "0",
                    "flag": "success",
                    "account": "201487033",
                    "usedTraffic": "39771.63"
                },
                "ecard":
                {
                    "flag": "success",
                    "cardbal": "10.42",
                    "paybal": "0.00"
                },
                "person": "王梓浓",
                "library":
                {
                    "hastime": true,
                    "opentime": "8:00",
                    "closetime": "18:00"
                }
            }
            """.data(using: .utf8)
            let decoder = JSONDecoder()
            let info = try decoder.decode(JsonDataType.self, from: data!)
            return info
        } catch (let error) {
            print(error)
            return nil
        }
    }
 */
}
