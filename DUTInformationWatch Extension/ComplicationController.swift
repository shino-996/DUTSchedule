//
//  ComplicationController.swift
//  DUTInformationWatch Extension
//
//  Created by shino on 08/03/2018.
//  Copyright © 2018 shino. All rights reserved.
//

import ClockKit
import CoreData

class ComplicationController: NSObject, CLKComplicationDataSource {
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
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
        let tuple = dataString(date: date)
        template.headerTextProvider = CLKSimpleTextProvider(text: tuple.0)
        template.body1TextProvider = CLKSimpleTextProvider(text: tuple.1)
        template.body2TextProvider = CLKSimpleTextProvider(text: tuple.2)
        let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        handler(entry)
    }
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "30G/20元")
            template.body1TextProvider = CLKSimpleTextProvider(text: "今天没课了~")
            template.body2TextProvider = CLKSimpleTextProvider(text: "明天还有2节课orz")
            handler(template)
    }
}

extension ComplicationController {
    func dataString(date: Date) -> (String, String, String) {
        let dataManager = DataManager()
        var tuple = ("", "", "")
        if let net = dataManager.net() {
            tuple.0 = net.flowStr() + "/" + net.costStr()
        }
        let courses = dataManager.courses(of: .today(date)).filter {
            return $0.startsection == date.section()
        }
        if courses.count == 0 {
            tuple.1 = "今天没有课了~"
            let tomorrowCourse = dataManager.courses(of: .nextDay(date))
            if tomorrowCourse.count == 0 {
                tuple.2 = "明天也没有课了~~"
            } else {
                tuple.2 = "明天还有\(tomorrowCourse.count)节课orz"
            }
        } else {
            let nowCourse = courses.first!
            tuple.1 = "第\(nowCourse.startsection)节" + nowCourse.course.name
            tuple.2 = nowCourse.place
        }
        return tuple
    }
}
