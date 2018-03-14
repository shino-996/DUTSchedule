//
//  ComplicationController.swift
//  DUTInformationWatch Extension
//
//  Created by shino on 08/03/2018.
//  Copyright © 2018 shino. All rights reserved.
//

import ClockKit
import DUTInfo

class ComplicationController: NSObject, CLKComplicationDataSource {
    var dutInfo: DUTInfo?
    var cacheInfo = CacheInfo()
    let courseInfo = CourseInfo()
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {}
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        var entry: CLKComplicationTimelineEntry
        let date = Date()
        if complication.family == .modularLarge {
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: otherString())
            let (course, place) = courseString(date: date)
            template.body1TextProvider = CLKSimpleTextProvider(text: course)
            template.body2TextProvider = CLKSimpleTextProvider(text: place)
            entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        } else {
            let template = CLKComplicationTemplateModularSmallSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: "DUT")
            entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        }
        handler(entry)
    }
    
    private func otherString() -> String {
        var netFlow = ""
        var ecardCost = ""
        netFlow = cacheInfo.netFlowText
        ecardCost = cacheInfo.ecardText
        return netFlow + "/" + ecardCost
    }
    
    private func courseString(date: Date) -> (course: String, place: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HHmm"
        let time = Int(dateFormatter.string(from: date))!
        let courseData = courseInfo.coursesToday(date).courses!
        var courseDictionary: [String: String]?
        for course in courseData {
            let coursenumberStr = course["coursenumber"]!
            switch coursenumberStr {
            case "1":
                if time <= 0935 {
                    courseDictionary = course
                }
            case "3":
                if time >= 0935 && time <= 1140 {
                    courseDictionary = course
                }
            case "5":
                if time >= 1140 && time <= 1505 {
                    courseDictionary = course
                }
            case "7":
                if time >= 1505 && time <= 1710 {
                    courseDictionary = course
                }
            default:
                courseDictionary = nil
            }
        }
        var courseString: String
        var placeString: String
        if let courseDictionary = courseDictionary {
            courseString = "第" + courseDictionary["coursenumber"]! + "节"
                               + " "
                               + courseDictionary["name"]!
            placeString = courseDictionary["place"]!
        } else {
            courseString = "没有课了~"
            let num = courseInfo.coursesNextDay(date).courses!.count
            if num != 0 {
                placeString = "明天有\(num)节课orz"
            } else {
                placeString = "明天也没有课~~"
            }
        }
        return (course: courseString, place: placeString)
    }
}
