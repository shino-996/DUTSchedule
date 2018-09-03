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
        let url = URL(string: "https://shino.ac.cn/api")!
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
}
