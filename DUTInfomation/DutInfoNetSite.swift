//
//  DutInfoNetSite.swift
//  DUTInfomation
//
//  Created by shino on 2017/9/13.
//  Copyright © 2017年 shino. All rights reserved.
//

import Foundation
import Fuzi
import PromiseKit

//校园网信息，只能在校园网环境下访问
//http://tulip.dlut.edu.cn
extension DUTInfo {
    //发送登录表求
    private func gotoNetPage() -> URLDataPromise {
        //需要在URL中加入时间戳参数
        let timeInterval = Date().timeIntervalSince1970
        let urlStr = "http://tulip.dlut.edu.cn/rpc?tm=\(Int(timeInterval))"
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        //将POST内容类型设置为json
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"jsonrpc\":\"2.0\",\"method\":\"/dllg/login/prepareLogin\",\"id\":\"1\",\"params\":[\"\(studentNumber)\",\"\(portalPassword)\",false]}".data(using: .utf8)
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 5
        session = URLSession(configuration: configuration)
        return session.dataTask(with: request)
    }
    
    private func netLoginVerify(_ data: Data) throws -> Promise<[String: Any]> {
        //返回数据为json格式，解析后是一个字典
        let parseDic = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            as! [String: Any]
        if parseDic["error"] != nil {
            throw DUTError.authError
        }
        return Promise(value: parseDic)
    }
    
    //解析出账号ID
    private func getNetID(_ parseDic: [String: Any]) -> Promise<String> {
        let array = parseDic["result"] as! [Any]
        let dictionary = array[0] as! [String: Any]
        //从一层一层的字典里取到用户的ID，用于之后的查询
        let id = dictionary["ID"] as! Int
        return Promise(value: "\(id)")
    }
    
    //发出查询余额请求
    private func requestNetMoney(_ id: String) -> URLDataPromise {
        let timeInterval = Date().timeIntervalSince1970
        let urlStr = "http://tulip.dlut.edu.cn/rpc?tm=\(Int(timeInterval))"
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"jsonrpc\": \"2.0\", \"method\": \"/user/charge/getChargeInfo\", \"id\": 2, \"params\": [\(id)]}".data(using: .utf8)
        return session.dataTask(with: request)
    }
    
    //解析出余额
    private func getNetMoney(_ data: Data) {
        let parseDictionary = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            as! [String: Any]
        //先取得余额和已使用金额用于输出
        let dictionary = parseDictionary["result"] as! [String: Any]
        //余额
        let balance = dictionary["balance"] as! Double
        //已使用
        //        let expenditure = dictionary["expenditure"] as! Double
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        userDefaults.set(balance, forKey: "NetCost")
        netCost = "\(balance)元"
    }
    
    //发送取得剩余流量请求
    private func requestNetFlow() -> URLDataPromise {
        let timeInterval = Date().timeIntervalSince1970
        let urlStr = "http://tulip.dlut.edu.cn/rpc?tm=\(Int(timeInterval))"
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        //设置查询时间
        let date = Date()
        let firstDateFormatter = DateFormatter()
        firstDateFormatter.dateFormat = "YYYY-MM"
        let firstDateString = firstDateFormatter.string(from: date) + "-01 00:00:00"
        let nowDateFormatter = DateFormatter()
        nowDateFormatter.dateFormat = "YYYY-MM-dd"
        let nowDateString = nowDateFormatter.string(from: date) + " 00:00:00"
        //"\\u4e0a\\u7f51\\u670d\\u52a1\"为"上网服务"两字，已转为unicode的转义字符
        request.httpBody = ("{\"jsonrpc\":\"2.0\",\"method\":\"/dllg/network/dayFlowRecords\",\"params\":[{\"pageIndex\":1,\"pageSize\":10,\"filter\":{\"fromDate\":\"" + firstDateString + "\",\"toDate\":\"" + nowDateString + "\",\"accountId\":\"\(studentNumber)\",\"businessInstanceName\":\"\(studentNumber)\",\"businessTypeName\":\"\\u4e0a\\u7f51\\u670d\\u52a1\"}}],\"id\":1}").data(using: .utf8)
        return session.dataTask(with: request)
    }
    
    private func getNetFlow(_ data: Data) {
        let pharseDic = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            as! [String: Any]
        let dictionary = pharseDic["result"] as! [String: Any]
        let array = dictionary["data"] as! [Any]
        let subDictionary = array[0] as! [String: Any]
        let remainFreeFlow = subDictionary["remainFreeFlow"] as! Double
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        userDefaults.set(false, forKey: "IsNetError")
        if remainFreeFlow < 1024 {
            userDefaults.set("\(Int(remainFreeFlow))MB", forKey: "NetFlow")
            netFlow = "\(Int(remainFreeFlow))MB"
        } else {
            userDefaults.set(String(format: "%.1lfGB", remainFreeFlow / 1024), forKey: "NetFlow")
            netFlow = String(format: "%.1lfGB", remainFreeFlow / 1024)
        }
    }
    
    private func netErrorHandle(_ error: Error) {
        if let error = error as? DUTError {
            if error == .authError {
                print("校园网用户名或密码错误！")
            }
        } else {
            let error = error as NSError
            if error.code == -1005 {
                print("不是校园网环境")
                let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
                userDefaults.set(true, forKey: "IsNetError")
                delegate.netErrorHandle()
            } else if error.code == -1001 {
                print("连接超时")
                let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
                userDefaults.set(true, forKey: "IsNetError")
                delegate.netErrorHandle()
            } else {
                fatalError()
            }
        }
    }
    
    func netInfo() {
        firstly(execute: gotoNetPage)
        .then(execute: netLoginVerify)
        .then(execute: getNetID)
        .then(execute: requestNetMoney)
        .then(execute: getNetMoney)
        .then(execute: requestNetFlow)
        .then(execute: getNetFlow)
        .catch(execute: netErrorHandle)
    }
}
