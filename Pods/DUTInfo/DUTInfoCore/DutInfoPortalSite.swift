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
            .then(on: queue, portalLogin)
            .map(on: queue, portalLoginVerify)
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
    
    //校园网信息
    public func netInfo() -> (netCost: Double, netFlow: Double)? {
        var value: (netCost: Double, netFlow: Double)?
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "portal.net.promise")
        firstly(execute: gotoPortalPage)
            .then(on: queue, portalLogin)
            .map(on: queue, portalLoginVerify)
            .then(on: queue, getPortalNetInfo)
            .map(on: queue, parsePortalNetInfo)
            .done(on: queue) {
                value = $0
            }.ensure(on: queue) {
                semaphore.signal()
            }.catch(on: queue) { error in
                print("portal net error")
                print(error)
            }
        _ = semaphore.wait(timeout: .distantFuture)
        return value
    }
    
    //玉兰卡余额
    public func moneyInfo() -> Double? {
        var value: Double?
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "portal.money.promise")
        firstly(execute: gotoPortalPage)
            .then(on: queue, portalLogin)
            .map(on: queue, portalLoginVerify)
            .then(on: queue, getPortalMoneyInfo)
            .map(on: queue, parsePortalMoneyInfo)
            .done(on: queue) {
                value = $0
            }.ensure(on: queue) {
                semaphore.signal()
            }.catch(on: queue) { error in
                print("portal money error")
                print(error)
            }
        _ = semaphore.wait(timeout: .distantFuture)
        return value
    }
    
    //学生姓名
    public func personInfo() -> String? {
        var value: String?
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "portal.person.promise")
        firstly(execute: gotoPortalPage)
            .then(on: queue, portalLogin)
            .map(on: queue, portalLoginVerify)
            .then(on: queue, getPortalPersonInfo)
            .map(on: queue, parsePortalPersonInto)
            .done(on: queue) {
                value = $0
            }.ensure(on: queue) {
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
    //进入门户主页, 主要是获取 cookie
    func gotoPortalPage() -> Promise<Rsp> {
        let url = URL(string: "https://sso.dlut.edu.cn/cas/login?service=https%3A%2F%2Fportal.dlut.edu.cn%2Ftp%2F")!
        let request = URLRequest(url: url)
        portalSession = URLSession(configuration: .ephemeral)
        return portalSession.dataTask(.promise, with: request)
    }
    
    func portalLogin(_ rsp: Rsp) throws -> Promise<Rsp> {
        let parseStr = try! HTMLDocument(data: rsp.data)
        let lt_ticket = parseStr.body?.children[0].children[6].attr("value")
        guard let cookieStorage = portalSession.configuration.httpCookieStorage else {
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
        return portalSession.dataTask(.promise, with: request)
    }
    
    private func portalLoginVerify(_ rsp: Rsp) -> Bool {
        let verifyStr = String(rsp: rsp)
        return verifyStr.hasPrefix("<META http-equiv=\"Refresh\" content=\"0; url=")
    }
    
    private func portalLoginVerify(_ rsp: Rsp) throws {
        if portalLoginVerify(rsp) {
            return
        } else {
            throw DUTError.authError
        }
    }
    
    private func getPortalNetInfo() -> Promise<Rsp> {
        let url = URL(string: "https://portal.dlut.edu.cn/tp/up/subgroup/getTrafficList")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{}".data(using: .utf8)
        return portalSession.dataTask(.promise, with: request)
    }
    
    private func parsePortalNetInfo(_ rsp: Rsp) -> (netCost: Double, netFlow: Double) {
        let jsonArray = try! JSONSerialization.jsonObject(with: rsp.data)
                   as! [[String: String]]
        let json = jsonArray[0]
        let cost = Double(json["fee"]!)!
        let flow = 30720 - Double(json["usedTraffic"]!)!
        return (cost, flow)
    }
    
    private func getPortalMoneyInfo() -> Promise<Rsp> {
        let url = URL(string: "https://portal.dlut.edu.cn/tp/up/subgroup/getCardMoney")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{}".data(using: .utf8)
        return portalSession.dataTask(.promise, with: request)
    }
    
    private func parsePortalMoneyInfo(_ rsp: Rsp) -> Double {
        let json = try! JSONSerialization.jsonObject(with: rsp.data)
                   as! [String: String]
        let cost = Double(json["cardbal"]!)!
        return cost
    }
    
    private func getPortalPersonInfo() -> Promise<Rsp> {
        let url = URL(string: "https://portal.dlut.edu.cn/tp/sys/uacm/profile/getUserById")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let studentNumber = DES.desStr(text: self.studentNumber, key_1: "tp", key_2: "des", key_3: "param")
        request.httpBody = """
        {
            "BE_OPT_ID": "\(studentNumber)"
        }
        """.data(using: .utf8)
        return portalSession.dataTask(.promise, with: request)
    }
    
    private func parsePortalPersonInto(_ rsp: Rsp) -> String {
        let json = try! JSONSerialization.jsonObject(with: rsp.data)
                   as! [String: Any]
        let name = json["USER_NAME"] as! String
        return name
    }

}
