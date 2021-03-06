//
//  JsonDataType.swift
//  DUTInfomation
//
//  Created by shino on 2018/5/31.
//  Copyright © 2018 shino. All rights reserved.
//

import Foundation

struct JsonDataType: Codable {
    let person: String!
    let net: Net!
    let ecard: Ecard!
    let library: Library!
    let course: [Course]!
    let test: [Test]!
}

enum LoadType: String {
    case net
    case ecard
    case course
    case test
    // 通过获得姓名来判断是否登录成功
    case person
}

extension JsonDataType {
    struct Net: Codable {
        let fee: String
        let usedTraffic: String
    }
    
    struct Library: Codable {
        let hastime: Bool
        let opentime: String?
        let closetime: String?
        let other: String?
    }
    
    struct Ecard: Codable {
        let cardbal: String
    }
    
    struct Course: Codable {
        let name: String
        let teacher: String
        let time: [time]?
    }
    
    struct Test: Codable {
        let name: String
        let date: String
        let starttime: String
        let endtime: String
        let place: String
    }
}

extension JsonDataType.Course {
    struct time: Codable {
        let place: String
        let startsection: Int
        let endsection: Int
        let startweek: Int
        let endweek: Int
        let weekday: Int
    }
}
