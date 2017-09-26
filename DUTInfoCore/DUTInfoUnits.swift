//
//  DUTInfoUnits.swift
//  DUTInfomation
//
//  Created by shino on 2017/9/11.
//  Copyright © 2017年 shino. All rights reserved.
//

import Foundation
import Fuzi

//对[XMLElement]的扩展，用于处理课程表字符串
extension Array where Element == XMLElement {
    func courseInfoDictionary(_ index_0: Int,
                          _ index_1: Int,
                          _ index_2: Int,
                          _ index_3: Int,
                          _ index_4: Int) -> [String: String] {
        //上课地点
        let metaPlaceStr = self[index_2].stringValue
        let placeIndex = metaPlaceStr.index(metaPlaceStr.startIndex, offsetBy: 3)
        let placeStr = String(metaPlaceStr[placeIndex...])
        //教学周
        let metaWeeknumberStr = self[index_3].stringValue
        let weeknumberIndex = metaWeeknumberStr.index(metaWeeknumberStr.endIndex, offsetBy: -1)
        let weeknumberStr = String(metaWeeknumberStr[..<weeknumberIndex])
        //周几的课
        let metaWeekStr = self[index_4].stringValue
        let weekCoursenumberStr = metaWeekStr.components(separatedBy: ",")
        let weekIndex = metaWeekStr.index(metaWeekStr.startIndex, offsetBy: 1)
        let weekStr = String(weekCoursenumberStr[0][weekIndex...])
        //第几节
        let metaCoursenumberStr = weekCoursenumberStr[1].trimmingCharacters(in: .whitespaces)
        let coursenumberStr = String(metaCoursenumberStr[..<metaCoursenumberStr.endIndex])
        let courseDic = ["name": self[index_0].stringValue,
                         "teacher": self[index_1].stringValue,
                         "place": placeStr,
                         "weeknumber": weeknumberStr,
                         "week": weekStr,
                         "coursenumber": coursenumberStr]
        return courseDic
    }
    
    func courseInfoDictionary(lastDictionary: [String: String],
                              _ index_0: Int,
                              _ index_1: Int,
                              _ index_2: Int) -> [String: String] {
        //上课地点
        let metaPlaceStr = self[index_0].stringValue
        let placeIndex = metaPlaceStr.index(metaPlaceStr.startIndex, offsetBy: 3)
        let placeStr = String(metaPlaceStr[placeIndex...])
        //教学周
        let metaWeeknumberStr = self[index_1].stringValue
        let weeknumberIndex = metaWeeknumberStr.index(metaWeeknumberStr.endIndex, offsetBy: -1)
        let weeknumberStr = String(metaWeeknumberStr[..<weeknumberIndex])
        //周几的课
        let metaWeekStr = self[index_2].stringValue
        let weekCoursenumberStr = metaWeekStr.components(separatedBy: ",")
        let weekIndex = metaWeekStr.index(metaWeekStr.startIndex, offsetBy: 1)
        let weekStr = String(weekCoursenumberStr[0][weekIndex...])
        //第几节
        let metaCoursenumberStr = weekCoursenumberStr[1].trimmingCharacters(in: .whitespaces)
        let coursenumberStr = String(metaCoursenumberStr[..<metaCoursenumberStr.endIndex])
        let courseDic = ["name": lastDictionary["name"]!,
                         "teacher": lastDictionary["teacher"]!,
                         "place": placeStr,
                         "weeknumber": weeknumberStr,
                         "week": weekStr,
                         "coursenumber": coursenumberStr]
        return courseDic
    }
    
    subscript(safe index: Int) -> Element? {
        if index >= 0 && index < self.count {
            return self[index]
        } else {
            return nil
        }
    }
}

//干TM的GBK编码
extension Data {
    var unicodeString: String {
        if let string = String(data: self, encoding: .utf8) {
            return string
        }
        let cfEncoding = CFStringEncodings.GB_18030_2000
        let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEncoding.rawValue))
        return NSString(data: self, encoding: encoding)! as String
    }
}
