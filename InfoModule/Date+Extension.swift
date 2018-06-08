//
//  Date+Extension.swift
//  DUTInfomation
//
//  Created by shino on 2018/6/2.
//  Copyright © 2018 shino. All rights reserved.
//

import Foundation

extension Date {
    func nextDate() -> Date {
        return Date(timeInterval: 60 * 60 * 24, since: self)
    }
    
    func lastDate() -> Date {
        return Date(timeInterval: -60 * 60 * 24, since: self)
    }
    
    func nextWeek() -> Date {
        return Date(timeInterval: 60 * 60 * 24 * 7, since: self)
    }
    
    func lastWeek() -> Date {
        return Date(timeInterval: -60 * 60 * 24 * 7, since: self)
    }
    
    func section() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HHmm"
        var section: Int
        switch Int(dateFormatter.string(from: self))! {
        case Int.min ..< 0935:
            section = 1
        case 0935 ..< 1140:
            section = 3
        case 1140 ..< 1505:
            section = 5
        case 1505 ..< 1710:
            section = 7
        case 1710 ..< 2035:
            section = 9
        default:
            section = 1
        }
        return section
    }
    
    func teachweek() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "w"
        return Int(dateFormatter.string(from: self))! - 9
    }
    
    func weekday() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "e"
        return Int(dateFormatter.string(from: self))! - 1
    }
    
    func weekDayStr() -> String {
        let str = ["日", "一", "二", "三", "四", "五", "六"]
        return str[weekday()]
    }
    
    static func weekDay(of num: Int) -> String {
        if !(0 ..< 7).contains(num) {
            return ""
        }
        let str = ["日", "一", "二", "三", "四", "五", "六"]
        return str[num]
    }
}
