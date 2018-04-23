//
//  DutInfoTeachSite.swift
//  DUTInfo
//
//  Created by shino on 2017/9/13.
//  Copyright © 2017年 shino. All rights reserved.
//

import Foundation
import Fuzi
import PromiseKit

//教务处网站信息，只有在校园网内网可以访问
//http://zhjw.dlut.edu.cn
//登录教务处网站

//接口
extension DUTInfo {
    //登录验证
    public func loginTeachSite() -> Bool {
        var value = false
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "teach.login.promise")
        firstly(execute: gotoTeachPage)
            .map(on: queue, teachLoginVerify)
            .done(on: queue) {
                value = $0
            }.ensure(on: queue) {
                semaphore.signal()
            }.catch(on: queue) { _ in
                value = false
            }
        _ = semaphore.wait(timeout: .distantFuture)
        return value
    }
    
    //课程信息
    public func courseInfo() -> [Course]? {
        var value: [Course]?
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "teach.course.promise")
        firstly(execute: gotoTeachPage)
            .map(on: queue, teachLoginVerify)
            .then(on: queue, getCourse)
            .map(on: queue, evaluateVerify)
            .map(on: queue, parseCourse)
            .done(on: queue) {
                value = $0
            }.ensure(on: queue) {
                semaphore.signal()
            }.catch(on: queue) { error in
                print("teach course error")
                print(error)
            }
        _ = semaphore.wait(timeout: .distantFuture)
        return value
    }
    
//    public func gradeInfo() -> [[String: String]] {
//        var value = [[String: String]]()
//        let semaphore = DispatchSemaphore(value: 0)
//        let queue = DispatchQueue(label: "teach.grade.promise")
//        firstly(execute: gotoTeachPage)
//            .then(on: queue, execute: teachLoginVerify)
//            .then(on: queue, execute: getGrade)
//            .then(execute: parseGrade)
//            .then(on: queue) { (grades: [[String: String]]) -> Void in
//                value = grades
//            }.always(on: queue) {
//            semaphore.signal()
//            }.catch(on: queue) { error in
//            print("teach grade error")
//            print(error)
//            }
//        _ = semaphore.wait(timeout: .distantFuture)
//        return value
//    }
    
    //考试信息
    public func testInfo() -> [[String: String]]? {
        var value: [[String: String]]?
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "test.promise")
        firstly(execute: gotoTeachPage)
            .map(on: queue, teachLoginVerify)
            .then(on: queue, getTest)
            .map(on: queue, parseTest)
            .done(on: queue) {
                value = $0
            }.ensure(on: queue) {
                semaphore.signal()
            }.catch(on: queue) { error in
                print("teach test error")
                print(error)
            }
        _ = semaphore.wait(timeout: .distantFuture)
        return value
    }
}

//干TM的GBK编码, 只有教务处网站会用到
extension String {
    init(rsp: Rsp) {
        if let str = String(data: rsp.data, encoding: .utf8) {
            self = str
        } else {
            let cfEncoding = CFStringEncodings.GB_18030_2000
            let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEncoding.rawValue))
            self = NSString(data: rsp.data, encoding: encoding)! as String
        }
    }
}

//接口实现
extension DUTInfo {
    func gotoTeachPage() -> Promise<Rsp> {
        let url = URL(string: "http://zhjw.dlut.edu.cn/loginAction.do")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = ("zjh=" + self.studentNumber + "&mm=" + self.teachPassword)
            .data(using: String.Encoding.utf8)
        teachSession = URLSession(configuration: .ephemeral)
        return teachSession.dataTask(.promise, with: request)
    }
    
    //验证是否登录成功
    func teachLoginVerify(_ rsp: Rsp) -> Bool {
        let str = String(rsp: rsp)
        let htmlStr = try! HTMLDocument(string: str)
        let verifyStr = htmlStr.title
        return verifyStr! == "学分制综合教务"
    }
    
    func teachLoginVerify(_ rsp: (data: Data, response: URLResponse)) throws {
        if teachLoginVerify(rsp) {
            return
        } else {
            throw DUTError.authError
        }
    }
    
    //查询本学期课程
    //进入本学期选课界面
    private func getCourse() -> Promise<Rsp> {
        let url = URL(string: "http://zhjw.dlut.edu.cn/xkAction.do?actionType=6")!
        let request = URLRequest(url: url)
        return teachSession.dataTask(.promise, with: request)
    }
    
    private func evaluateVerify(_ rsp: Rsp) throws -> String {
        let str = String(rsp: rsp)
        let parseString = try! HTMLDocument(string: str)
        guard let verifyStr = parseString.title else {
            return str
        }
        if verifyStr.trimmingCharacters(in: .whitespacesAndNewlines) == "错误信息" {
            throw DUTError.evaluateError
        } else {
            return str
        }
    }
    
    //解析出各门课程
    private func parseCourse(_ string: String) -> [Course] {
        let parseString = try! HTMLDocument(string: string)
        let courseSource = parseString.xpath("//table[@class=\"displayTag\"]/tr[@class=\"odd\"]")
        var courses = [Course]()
        for courseData in courseSource {
            let items = courseData.xpath("./td")
            if items.count > 7 {
                var course = Course(name: "", teacher: "", time: nil)
                course.name = items[2].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                course.teacher = items[7].stringValue
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .filter {$0 != "*"}
                let teachWeeks = items[11].stringValue
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .filter {$0.unicodeScalars.first?.value ?? 128 < 128}
                    .split(separator: "-")
                if teachWeeks.count == 0 {
                    courses.append(course)
                    continue
                }
                var courseTime = Time(place: "", startsection: 0, endsection: 0, week: 0, teachweek: [])
                let startTeachWeek = Int(teachWeeks.first!)!
                let endTeachWeek = Int(teachWeeks.last!)!
                for i in startTeachWeek ... endTeachWeek {
                    courseTime.teachweek.append(i)
                }
                courseTime.week = Int(items[12].stringValue.trimmingCharacters(in: .whitespacesAndNewlines))!
                courseTime.startsection = Int(items[13].stringValue.trimmingCharacters(in: .whitespacesAndNewlines))!
                courseTime.endsection = courseTime.startsection - 1 +  Int(items[14].stringValue.trimmingCharacters(in: .whitespacesAndNewlines))!
                courseTime.place = items[16].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    + " "
                    + items[17].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if course.time == nil {
                    course.time = []
                }
                course.time!.append(courseTime)
                courses.append(course)
            } else {
                var course = courses.popLast()!
                let teachWeeks = items[0].stringValue
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .filter {$0.unicodeScalars.first?.value ?? 128 < 128}
                    .split(separator: "-")
                if teachWeeks.count == 0 {
                    courses.append(course)
                    continue
                }
                var courseTime = Time(place: "", startsection: 0, endsection: 0, week: 0, teachweek: [])
                let startTeachWeek = Int(teachWeeks.first!)!
                let endTeachWeek = Int(teachWeeks.last!)!
                for i in startTeachWeek ... endTeachWeek {
                    courseTime.teachweek.append(i)
                }
                courseTime.week = Int(items[1].stringValue.trimmingCharacters(in: .whitespacesAndNewlines))!
                courseTime.startsection = Int(items[2].stringValue.trimmingCharacters(in: .whitespacesAndNewlines))!
                courseTime.endsection = courseTime.startsection - 1 + Int(items[3].stringValue.trimmingCharacters(in: .whitespacesAndNewlines))!
                courseTime.place = items[5].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    + " "
                    + items[6].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if course.time == nil {
                    course.time = []
                }
                course.time!.append(courseTime)
                courses.append(course)
            }
        }
        return courses
    }
    
    //查询本学期成绩
    //进入本学期成绩界面
    private func getGrade() -> Promise<Rsp> {
        let url = URL(string: "http://zhjw.dlut.edu.cn/bxqcjcxAction.do")!
        let request = URLRequest(url: url)
        return teachSession.dataTask(.promise, with: request)
    }
    
    //解析出各科成绩
    private func parseGrade(_ rsp: Rsp) {
        let str = String(rsp: rsp)
        let parseString = try! HTMLDocument(string: str)
        //找到分数所在的标签
        let courses = parseString.xpath("//table[@class=\"displayTag\"]/tr[@class=\"odd\"]")
        for course in courses {
            for item in course.xpath("./td") {
                print(item.stringValue.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
    }

    //查询考试安排
    private func getTest() -> Promise<Rsp> {
        let url = URL(string: "http://zhjw.dlut.edu.cn/ksApCxAction.do?oper=getKsapXx")!
        let request = URLRequest(url: url)
        return teachSession.dataTask(.promise, with: request)
    }
    // 解析考试信息
    private func parseTest(_ rsp: Rsp) -> [[String: String]] {
        let str = String(rsp: rsp)
        let parseString = try! HTMLDocument(string: str)
        let courses = parseString.xpath("//table[@class=\"displayTag\"]/tr[@class=\"odd\"]")
        var testData = [[String: String]]()
        for course in courses {
            var testDic = [String: String]()
            let item = course.xpath("./td")
            testDic["name"] = item[4].stringValue
            testDic["teachweek"] = item[0].stringValue.filter{ $0.unicodeScalars.first?.value ?? 128 < 128 }
            testDic["date"] = item[5].stringValue
            testDic["time"] = item[6].stringValue
            testDic["place"] = item[2].stringValue + " " + item[3].stringValue
            testData.append(testDic)
        }
        return testData
    }
}
