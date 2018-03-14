//
//  DutInfoPortalSite.swift
//  DUTInfo
//
//  Created by shino on 2017/9/25.
//  Copyright © 2017年 shino. All rights reserved.
//

import Foundation
import Fuzi
import PromiseKit

//新版校园门户信息，可以通过外网访问
//http://one.dlut.edu.cn/

//接口
extension DUTInfo {
    //校园门户登录验证
    public func loginPortal() -> Bool {
        var value = false
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "portal.login.promise")
        firstly(execute: gotoPortalPage)
            .then(on: queue, execute: portalLogin)
            .then(on: queue, execute: portalLoginVerify)
            .then(on: queue) { (isLogin: Bool) -> Void in
                value = isLogin
            }.always(on: queue) {
                semaphore.signal()
            }.catch(on: queue) { _ in
                value = false
            }
        _ = semaphore.wait(timeout: .distantFuture)
        return value
    }
    
    //校园网信息
    public func netInfo() -> (netCost: Double, netFlow: Double) {
        var value = (netFlow: 0.0, netCost: 0.0)
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "portal.net.promise")
        firstly(execute: gotoPortalPage)
            .then(on: queue, execute: portalLogin)
            .then(on: queue, execute: portalLoginVerify)
            .then(on: queue, execute: getPortalNetInfo)
            .then(on: queue, execute: parsePortalNetInfo)
            .then(on: queue) { (netInfo: (netCost: Double, netFlow: Double)) -> Void in
                value = netInfo
            }.always(on: queue) {
                semaphore.signal()
            }.catch(on: queue) { error in
                print("portal net error")
                print(error)
            }
        _ = semaphore.wait(timeout: .distantFuture)
        return value
    }
    
    //玉兰卡余额
    public func moneyInfo() -> Double {
        var value = 0.0
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "portal.money.promise")
        firstly(execute: gotoPortalPage)
            .then(on: queue, execute: portalLogin)
            .then(on: queue, execute: portalLoginVerify)
            .then(on: queue, execute: getPortalMoneyInfo)
            .then(on: queue, execute: parsePortalMoneyInfo)
            .then(on: queue) { (cost: Double) -> Void in
                value = cost
            }.always(on: queue) {
                semaphore.signal()
            }.catch(on: queue) { error in
                print("portal money error")
                print(error)
            }
        _ = semaphore.wait(timeout: .distantFuture)
        return value
    }
    
    //学生姓名
    public func personInfo() -> String {
        var value = ""
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "portal.person.promise")
        firstly(execute: gotoPortalPage)
            .then(on: queue, execute: portalLogin)
            .then(on: queue, execute: portalLoginVerify)
            .then(on: queue, execute: getPortalPersonInfo)
            .then(on: queue, execute: parsePortalPersonInto)
            .then(on: queue) { (name: String) -> Void in
                value = name
            }.always(on: queue) {
                semaphore.signal()
            }.catch(on: queue) { error in
                print("portal person error")
                print(error)
            }
        _ = semaphore.wait(timeout: .distantFuture)
        return value
    }
}

//接口实现
extension DUTInfo {
    func gotoPortalPage() -> URLDataPromise {
        let url = URL(string: "https://sso.dlut.edu.cn/cas/login?service=https%3A%2F%2Fportal.dlut.edu.cn%2Ftp%2F")!
        let request = URLRequest(url: url)
        newPortalSession = URLSession(configuration: .ephemeral)
        return newPortalSession.dataTask(with: request)
    }
    
    func portalLogin(_ data: Data) throws -> URLDataPromise {
        let parseStr = try! HTMLDocument(data: data)
        let lt_ticket = parseStr.body?.children[0].children[6].attr("value")
        guard let cookieStorage = newPortalSession.configuration.httpCookieStorage else {
            print("session中没有cookie")
            throw DUTError.netError
        }
        guard let cookies = cookieStorage.cookies(for: URL(string: "https://sso.dlut.edu.cn")!) else {
            print("cookie为空")
            throw DUTError.netError
        }
        var cookieString = "jsessionid="
        for cookie in cookies {
            if cookie.name == "JSESSIONID" {
                cookieString += cookie.value
            }
        }
        let url = URL(string: "https://sso.dlut.edu.cn/cas/login;" + cookieString + "?service=https%3A%2F%2Fportal.dlut.edu.cn%2Ftp%2F")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = ("rsa=" + DES.desStr(text: studentNumber + portalPassword + lt_ticket!, key_1: "1", key_2: "2", key_3: "3") + "&ul=9&pl=14&" + lt_ticket! + "&execution=e1s1&_eventId=submit").data(using: .utf8)!
        return newPortalSession.dataTask(with: request)
    }
    
    private func portalLoginVerify(_ data: Data) -> Bool {
        let verifyStr = String(data: data, encoding: .utf8)!
        return verifyStr.hasPrefix("<META http-equiv=\"Refresh\" content=\"0; url=")
    }
    
    private func portalLoginVerify(_ data: Data) throws {
        let verifyStr = String(data: data, encoding: .utf8)!
        if verifyStr.hasPrefix("<META http-equiv=\"Refresh\" content=\"0; url=") {
            return
        } else {
            throw DUTError.authError
        }
    }
    
    private func getPortalNetInfo() -> URLDataPromise {
        let url = URL(string: "https://portal.dlut.edu.cn/tp/up/subgroup/getTrafficList")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{}".data(using: .utf8)
        return newPortalSession.dataTask(with: request)
    }
    
    private func parsePortalNetInfo(_ netInfoData: Data) -> (netCost: Double, netFlow: Double) {
        let jsonArray = try! JSONSerialization.jsonObject(with: netInfoData)
                   as! [[String: String]]
        let json = jsonArray[0]
        let cost = Double(json["fee"]!)!
        let flow = 30720 - Double(json["usedTraffic"]!)!
        return (cost, flow)
    }
    
    private func getPortalMoneyInfo() -> URLDataPromise {
        let url = URL(string: "https://portal.dlut.edu.cn/tp/up/subgroup/getCardMoney")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{}".data(using: .utf8)
        return newPortalSession.dataTask(with: request)
    }
    
    private func parsePortalMoneyInfo(_ moneyInfoData: Data) -> Double {
        let json = try! JSONSerialization.jsonObject(with: moneyInfoData)
                   as! [String: String]
        let cost = Double(json["cardbal"]!)!
        return cost
    }
    
    private func getPortalPersonInfo() -> URLDataPromise {
        let url = URL(string: "https://portal.dlut.edu.cn/tp/sys/uacm/profile/getUserById")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let studentNumber = DES.desStr(text: self.studentNumber, key_1: "tp", key_2: "des", key_3: "param")
        request.httpBody = """
        {
            "ID_NUMBER": "\(studentNumber)"
        }
        """.data(using: .utf8)
        return newPortalSession.dataTask(with: request)
    }
    
    private func parsePortalPersonInto(_ personInfoData: Data) -> String {
        let json = try! JSONSerialization.jsonObject(with: personInfoData)
                   as! [String: Any]
        let name = json["USER_NAME"] as! String
        return name
    }

}
