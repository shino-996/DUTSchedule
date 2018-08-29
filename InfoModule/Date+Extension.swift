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
    
    func day() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return Int(dateFormatter.string(from: self))!
    }
    
    private func dateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
    
    static func startDate() -> Date {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd HH:mm:ss"
        let dateString = date.dateString() + " 00:00:00"
        return dateFormatter.date(from: dateString)!
    }
    
    static func endDate() -> Date {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = date.dateString() + " 23:59:59"
        return dateFormatter.date(from: dateString)!
    }
    
    init(section: UInt) {
        self.init()
        var timeString: String?
        switch section {
        case 0 ... 1:
            timeString = "0800"
        case 2:
            timeString = "0845"
        case 3:
            timeString = "0935"
        case 4:
            timeString = "1055"
        case 5:
            timeString = "1330"
        case 6:
            timeString = "1415"
        case 7:
            timeString = "1535"
        case 8:
            timeString = "1615"
        default:
            timeString = nil
        }
        if let timeString = timeString {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HHmm"
            self = dateFormatter.date(from: self.dateString() + " " + timeString)!
        } else {
            self = Date.endDate()
        }
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
            section = Int.max
        }
        return section
    }
    
    func teachweek() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "w"
        return Int(dateFormatter.string(from: self))! - 35
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
