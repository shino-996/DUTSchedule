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
    lazy var dataManager = DataManager()
    var courseInfo: (uptime: Int, courses: [TimeData])!
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.backward, .forward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(Date.startDate())
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(Date.endDate())
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        updateCourse()
        let currentSection = date.section()
        let lastSection = courseInfo.courses.last?.startsection ?? 0
        var entryArray: [CLKComplicationTimelineEntry]? = nil
        if currentSection > lastSection {
            entryArray = nil
        } else {
            entryArray = (currentSection + 2 ... Int(lastSection) + 2).compactMap {
                if $0 % 2 == 0 {
                    return nil
                }
                return infoEntry(date: Date(section: UInt($0)))
            }
        }
        handler(entryArray)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        updateCourse()
        let currentSection = date.section()
        var entryArray: [CLKComplicationTimelineEntry]? = nil
        entryArray = (1 ..< currentSection).compactMap {
            if $0 % 2 == 0 {
                return nil
            }
            return infoEntry(date: Date(section: UInt($0)))
        }
        handler(entryArray)
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        updateCourse()
        let entry = infoEntry(date: Date())
        handler(entry)
    }
    
    func getTimelineAnimationBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineAnimationBehavior) -> Void) {
        handler(.always)
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
    func infoEntry(date: Date) -> CLKComplicationTimelineEntry {
        let template = CLKComplicationTemplateModularLargeStandardBody()
        let tuple = dataString(date: date)
        template.headerTextProvider = CLKSimpleTextProvider(text: tuple.0)
        template.body1TextProvider = CLKSimpleTextProvider(text: tuple.1)
        template.body2TextProvider = CLKSimpleTextProvider(text: tuple.2)
        return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
    }
    
    func updateCourse() {
        let today = Date()
        if courseInfo != nil {
            if today.day() == courseInfo.uptime {
                return
            }
        }
        let courses = dataManager.courses(of: .today(today))
        courseInfo = (today.day(), courses)
    }
    
    func dataString(date: Date) -> (String, String, String) {
        var tuple = ("", "", "")
        if let net = dataManager.net() {
            tuple.0 = net.flowStr() + "/" + net.costStr()
        }
        let courses = courseInfo.courses.filter {
            return $0.startsection >= date.section()
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
