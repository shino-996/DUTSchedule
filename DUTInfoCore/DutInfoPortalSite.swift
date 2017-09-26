//
//  DutInfoPortalSite.swift
//  DUTInfomation
//
//  Created by shino on 2017/9/13.
//  Copyright © 2017年 shino. All rights reserved.
//

import Foundation
import Fuzi
import PromiseKit

//校园门户信息，可以通过外网访问
//http://portal.dlut.edu.cn/

//接口
extension DUTInfo {
    //登录验证
    func loginPortalSite(succeed: @escaping () -> Void = {}, failed: @escaping () -> Void = {}) {
        firstly(execute: getLoginPortalURL)
            .then(execute: gotoPortalPage)
            .then(execute: portalLoginVerify)
            .then { (isLogin: Bool) -> Void in
                if isLogin {
                    succeed()
                }
            }.catch { error in
                print(error)
                failed()
            }
    }
    
    //获取课程表，handle闭包对获取到的信息进行处理
    func scheduleInfo() {
        firstly(execute: getLoginPortalURL)
            .then(execute: gotoPortalPage)
            .then(execute: portalLoginVerify)
            .then(execute: gotoPortalMainPage)
            .then(execute: gotoMyInfoPage)
            .then(execute: clickMyTeachButton)
            .then(execute: getMyTeachURL)
            .then(execute: gotoMyTeachPage)
            .then(execute: gotoMySchedulePage)
            .then(execute: getSchedule)
            .catch(execute: portalErrorHandle)
    }
}

//接口实现
extension DUTInfo {
    //登录校园门户，需要跳转几次
    //打开登录链接
    //因为每次打开都会生成一个登录用的ID，所以要特意打开这个链接
    private func getLoginPortalURL() -> URLDataPromise {
        let url = URL(string: "http://portal.dlut.edu.cn/cas/login?service=http%3A%2F%2Fportal.dlut.edu.cn%2Fcas.jsp")
        let request = URLRequest(url: url!)
        portalSession = URLSession(configuration: .ephemeral)
        return portalSession.dataTask(with: request)
    }
    
    //获取登录用的"lt"字符串，之后登录
    private func gotoPortalPage(_ data: Data) -> URLDataPromise {
        let requestStr = data.unicodeString
        let pharseStr = try! HTMLDocument(string: requestStr)
        let ltID = pharseStr.body?
            .children[0].children[5].children[0].children[0]
            .children[1].children[0].children[1].children[1]
            .children[1].children[1].children[1].attr("value")
        let url = URL(string: "http://portal.dlut.edu.cn/cas/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = ("encodedService=http%253a%252f%252fportal.dlut.edu.cn%252fcas.jsp&service=http%3A%2F%2Fportal.dlut.edu.cn%2Fcas.jsp&serviceName=null&action=DCPLogin&inputname=\(studentNumber)&selmail=1&username=\(studentNumber)&password=\(portalPassword)&lt=\(ltID!)&userNameType=cardID&Submit=%B5%C7%C2%BC")
            .data(using: .utf8)
        return portalSession.dataTask(with: request)
    }
    
    //验证是否登录成功，重载函数是因为后面有的功能不需要主页的HTMl
    private func portalLoginVerify(_ data: Data) throws -> Bool {
        let requestStr = data.unicodeString
        let parseStr = try! HTMLDocument(string: requestStr)
        let verifyElem = parseStr.body?
            .children[0].tag
        if verifyElem! != "noscript" {
            throw DUTError.authError
        }
        return true
    }
    
    private func portalLoginVerify(_ data: Data) throws -> Promise<HTMLDocument> {
        let requestStr = data.unicodeString
        let parseStr = try! HTMLDocument(string: requestStr)
        let verifyElem = parseStr.body?
            .children[0].tag
        if verifyElem! != "noscript" {
            throw DUTError.authError
        }
        return Promise(value: parseStr)
    }
    
    //得到校园门户主页的URL，后面查课程表和成绩会用到
    private func gotoPortalMainPage(_ parseStr: HTMLDocument) throws -> URLDataPromise {
        let urlStr = parseStr.body?
            .children[0].children[0].children[0].attr("href")
        let url = URL(string: urlStr!)!
        let request = URLRequest(url: url)
        return portalSession.dataTask(with: request)
    }
    
    //校园卡余额及电子支付余额信息
    private func getEcardURL(_: Bool) -> URLDataPromise {
        let url = URL(string: "http://portal.dlut.edu.cn/eapdomain/neudcp/sso/ecard_query_new.jsp")!
        let request = URLRequest(url: url)
        return portalSession.dataTask(with: request)
    }
    
    //这个页面要跳转一下……
    private func gotoEcardPage(_ data: Data) -> URLDataPromise {
        let requestStr = data.unicodeString
        let parseStr = try! HTMLDocument(string: requestStr)
        let urlStr = parseStr.body?
            .children[0].children[0].children[0].attr("href")
        let url = URL(string: urlStr!)!
        let request = URLRequest(url: url)
        return portalSession.dataTask(with: request)
    }
    
    private func getEcardInfo(_ data: Data) {
        let parseStr = try! HTMLDocument(data: data)
        let ecardMoney = parseStr.body?
            .children[0].children[0].children[2].children[0]
            .children[0].stringValue
        ecardCost = ecardMoney! + "元"
    }
    
    func ecardInfo() {
        firstly(execute: getLoginPortalURL)
        .then(execute: gotoPortalPage)
        .then(execute: portalLoginVerify)
        .then(execute: getEcardURL)
        .then(execute: gotoEcardPage)
        .then(execute: getEcardInfo)
        .catch(execute: portalErrorHandle)
    }
    
    //课程表信息
    //之所以要一个个界面跳转是因为URL中TM中有上一个界面中的标识ID
    //前往“个人信息"界面
    private func gotoMyInfoPage(_ data: Data) -> URLDataPromise {
        let parseStr = try! HTMLDocument(data: data)
        let urlStr = parseStr.body?
            .children[0].children[23].children[0].children[0]
            .children[0].children[0].children[0].children[0]
            .children[11].children[0].attr("href")
        let url = URL(string: urlStr!)!
        let request = URLRequest(url: url)
        return portalSession.dataTask(with: request)
    }
    
    //准备前往"我的教务信息界面"，相当于点了一下"我的教务信息"按钮
    private func clickMyTeachButton(_ data: Data) -> URLDataPromise {
        let parseStr = try! HTMLDocument(data: data)
        let urlStr = parseStr.body?
            .children[0].children[23].children[1].children[0]
            .children[0].children[0].children[0].children[2]
            .children[2].children[0].children[0].children[1]
            .children[0].attr("href")
        let url = URL(string: urlStr!)!
        let request = URLRequest(url: url)
        return portalSession.dataTask(with: request)
    }
    
    //"我的教务信息界面要进行一次跳转……"
    private func getMyTeachURL(_ data: Data) -> URLDataPromise {
        let parseStr = try! HTMLDocument(data: data)
        let str = parseStr.body?
            .children[0].children[23].children[1].children[0]
            .children[2].children[0].children[0].children[0]
            .children[0].children[0].children[1].children[0]
            .children[1].children[0].attr("src")
        let url = URL(string: "http://portal.dlut.edu.cn" + str!)!
        let request = URLRequest(url: url)
        return portalSession.dataTask(with: request)
    }
    
    //总算进来了
    private func gotoMyTeachPage(_ data: Data) -> URLDataPromise {
        let requestStr = data.unicodeString
        let parseStr = try! HTMLDocument(string: requestStr)
        let urlStr = parseStr.body?
            .children[0].children[0].children[0].attr("href")
        let url = URL(string: urlStr!)!
        let request = URLRequest(url: url)
        return portalSession.dataTask(with: request)
    }
    
    //前往课程表界面
    private func gotoMySchedulePage(_ data: Data) -> URLDataPromise {
        let parseStr = try! HTMLDocument(data: data)
        //POST取得课程表需要用到的reportid参数
        /*在这个HTML中以
         <a href="javascript:viewFile('1','47d68ba0-3d68-4832-a93c-2c9861396a75','本科生个人课程信息查询')">本科生个人课程信息查询</a>
         形式存在，需要分割字符串
         */
        let reportIDStr = parseStr.body?
            .children[0].children[0].children[2].children[0]
            .children[1].children[0].attr("href")?.components(separatedBy: "\'")
        let reportID = reportIDStr![3]
        let url = URL(string: "http://portal.dlut.edu.cn/report/Report-ResultAction.do?newReport=true")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let xq_dummy = "秋季学期".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        request.httpBody = ("xn_dummy=2017-2018&xq_dummy="
            + xq_dummy
            + "&reportId="
            + reportID
            + "&newReport=true&xn=2017-2018&xq=1").data(using: .utf8)
        return portalSession.dataTask(with: request)
    }
    
    private func getSchedule(_ data: Data) {
        let parseStr = try! HTMLDocument(data: data)
        let courses = parseStr.body?
            .children[1].children[1].children[0].children[0]
            .children[0].children[0].children[0].children[0]
            .children[0].children[0].children[0].children
        var courseData = [[String: String]]()
        for course in courses! {
            //这里只能判断<tr>标签里的"style"属性是不是"height:18pt"来分辨课程所在的表格
            guard let isCourseStr = course.attr("style") else {
                continue
            }
            if isCourseStr != "height:18pt;" {
                continue
            }
            //对于一周上多节课，中有一个表格中包含所有信息（9个），其余表格中只有6个信息
            let courseInfo = course.children
            if courseInfo.count == 9 {
                let courseDic = courseInfo.courseInfoDictionary(1, 8, 5, 6, 7)
                courseData.append(courseDic)
            } else {
                let lastCourse = courseData.last!
                let courseDic = courseInfo.courseInfoDictionary(lastDictionary: lastCourse, 2, 3, 4)
                courseData.append(courseDic)
            }
        }
        delegate.setSchedule(courseData)
    }
    
    private func portalErrorHandle(_ error: Error) {
        print(error)
        if let error = error as? DUTError {
            if error == .authError {
                print("校园门户用户名或密码错误！")
            }
        } else {
            print("其他错误")
        }
        delegate.netErrorHandle()
    }
}
