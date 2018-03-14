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
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.backward, .forward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        let date = Date()
        let template = CLKComplicationTemplateModularLargeStandardBody()
        template.headerTextProvider = CLKSimpleTextProvider(text: otherString())
        let (course, place) = courseString(date: date)
        template.body1TextProvider = CLKSimpleTextProvider(text: course)
        template.body2TextProvider = CLKSimpleTextProvider(text: place)
        let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        handler(entry)
    }
    
    private func otherString() -> String {
        let cacheInfo = CacheInfo()
        let netFlow = cacheInfo.netFlowText
        let ecardCost = cacheInfo.ecardText
        return netFlow + "/" + ecardCost
    }
    
    private func courseString(date: Date) -> (course: String, place: String) {
        let courseInfo = CourseInfo()
        var courseString: String
        var placeString: String
        if let courseDictionary = courseInfo.courseNow().course {
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
