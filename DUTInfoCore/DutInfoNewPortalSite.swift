//
//  DutInfoNewPortalSite.swift
//  DUTInfomation
//
//  Created by shino on 2017/9/25.
//  Copyright © 2017年 shino. All rights reserved.
//

import Foundation
import Fuzi
import PromiseKit
import JavaScriptCore

//新版校园门户信息，可以通过外网访问
//http://one.dlut.edu.cn/
extension DUTInfo {
    private func gotoNewPortalPage() -> URLDataPromise {
        let url = URL(string: "http://sso.dlut.edu.cn/cas/login?service=http:%2F%2Fone.dlut.edu.cn%2Ftp%2F")!
        let request = URLRequest(url: url)
        newPortalSession = URLSession(configuration: .ephemeral)
        return newPortalSession.dataTask(with: request)
    }
    
    private func loginNewPortal(_ data: Data) -> URLDataPromise {
        let parseStr = try! HTMLDocument(data: data)
        let lt_ticket = parseStr.body?.children[0].children[6].attr("value")
        let url = URL(string: "http://sso.dlut.edu.cn/cas/login?service=http:%2F%2Fone.dlut.edu.cn%2Ftp%2F")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = ("rsa=" + self.desEncode(studentNumber + portalPassword + lt_ticket!) + "&ul=9&pl=14&" + lt_ticket! + "&execution=e1s1&_eventId=submit").data(using: .utf8)!
        return newPortalSession.dataTask(with: request)
    }
    
    private func getNewPortalNetInfo(_: Data) -> URLDataPromise {
        let url = URL(string: "http://one.dlut.edu.cn/tp/up/subgroup/getTrafficList")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{}".data(using: .utf8)
        return newPortalSession.dataTask(with: request)
    }
    
    private func parseNewPortalNetInfo(_ netInfoData: Data) -> Void {
        let jsonArray = try! JSONSerialization.jsonObject(with: netInfoData)
                   as! [[String: String]]
        let json = jsonArray[0]
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        netCost = json["fee"]! + "元"
        userDefaults.set(netCost, forKey: "NetCost")
        let flow = Double(json["usedTraffic"]!)!
        if flow < 1024 {
            netFlow = "\(flow))MB"
            userDefaults.set(netFlow, forKey: "NetFlow")
        } else {
            netFlow = String(format: "%.1lfGB", flow / 1024)
            userDefaults.set(netFlow, forKey: "NetFlow")
        }
    }
    
    private func getNewPortalMoneyInfo() -> URLDataPromise {
        let url = URL(string: "http://one.dlut.edu.cn/tp/up/subgroup/getCardMoney")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{}".data(using: .utf8)
        return newPortalSession.dataTask(with: request)
    }
    
    private func parseNewPortalMoneyInfo(_ moneyInfoData: Data) -> Void {
        let json = try! JSONSerialization.jsonObject(with: moneyInfoData)
                   as! [String: String]
        ecardCost = json["cardbal"]! + "元"
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        userDefaults.set(ecardCost, forKey: "EcardCost")
    }
    
    private func desEncode(_ text: String) -> String {
        let jscontext = JSContext()
        if let jsPath = Bundle.main.path(forResource: "des", ofType: "js") {
            let jsStr = try! String(contentsOfFile: jsPath)
            _ = jscontext?.evaluateScript(jsStr)
        } else {
            fatalError()
        }
        let jsFunc = jscontext?.objectForKeyedSubscript("strEnc")
        let encode = jsFunc!.call(withArguments: [text, "1", "2", "3"])
        return encode!.toString()
    }
    
    func newPortalNetInfo() {
        firstly(execute: gotoNewPortalPage)
        .then(execute: loginNewPortal)
        .then(execute: getNewPortalNetInfo)
        .then(execute: parseNewPortalNetInfo)
        .then(execute: getNewPortalMoneyInfo)
        .then(execute: parseNewPortalMoneyInfo)
        .catch { error in
            print(error)
            fatalError()
        }
    }
}
