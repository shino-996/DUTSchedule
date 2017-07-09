//
//  TeachInfo.swift
//  DUTInfomation
//
//  Created by shino on 2017/7/3.
//  Copyright © 2017年 shino. All rights reserved.
//

import PromiseKit
import Fuzi
import Foundation

class DUTInfo: NSObject {
    //学号
    var studentNumber: String!
    //教务处密码，默认为身份证号后6位
    var teachPassword: String!
    //校园门户密码，默认为身份证号后6位
    var portalPassword: String!
    
    var netCost: String!
    var netFlow: String!
    var ecardCost: String!
}

//干TM的GBK编码
extension DUTInfo {
    func utf8String(fromGBKData data: Data) -> String {
        let cfEncoding = CFStringEncodings.GB_18030_2000
        let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEncoding.rawValue))
        return NSString(data: data, encoding: encoding)! as String
    }
}


//教务处网站信息，只有在校园网内网可以访问
//http://zhjw.dlut.edu.cn

//登录教务处网站
extension DUTInfo {
    fileprivate func loginTeachSite() -> URLDataPromise {
        let url = URL(string: "http://zhjw.dlut.edu.cn/loginAction.do")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = ("zjh=" + self.studentNumber + "&mm=" + self.teachPassword)
                            .data(using: String.Encoding.utf8)
        return URLSession.shared.dataTask(with: request)
    }
}

//查询本学期成绩
extension DUTInfo {
    //进入本学期成绩界面
    fileprivate func gotoGradePage(_ data: Data) -> URLDataPromise {
        let url = URL(string: "http://zhjw.dlut.edu.cn/bxqcjcxAction.do")!
        let request = URLRequest(url: url)
        return URLSession.shared.dataTask(with: request)
    }
    
    //解析出各科成绩
    fileprivate func getGrade(_ data: Data) {
        let requestString = utf8String(fromGBKData: data)
        let pharseString = try! HTMLDocument(string: requestString)
        //找到分数所在的标签
        let grades = pharseString.body?
                    .children[0].children[3].children[0].children[0]
                    .children[0].children[0].children
        for grade in grades! {
            //去掉表头标签
            guard grade.attr("class") != nil else {
                continue
            }
            //去掉字符中空白符
            let className = grade.children[2].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let classCredit = grade.children[4].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            var classGrade = grade.children[6].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if classGrade == "" {
                classGrade = "成绩未出"
            }
            print(className + ", " + classCredit + ", " + classGrade)
        }
    }
    
    func gradeInfo() {
        firstly(execute: loginTeachSite)
            .then(execute: gotoGradePage)
            .then(execute: getGrade)
            .catch { error in
                print(error)
            }
    }
}

//查询考试安排
//因为我小学期没有考试……等抓到有考试的人再用他的账号抓吧【
extension DUTInfo {
    fileprivate func gotoTestPage(_ data: Data) -> URLDataPromise {
        let url = URL(string: "http://zhjw.dlut.edu.cn/ksApCxAction.do?oper=getKsapXx")!
        let request = URLRequest(url: url)
        return URLSession.shared.dataTask(with: request)
    }
    
    fileprivate func testPrint(_ data: Data) {
        let str = utf8String(fromGBKData: data)
        print(str)
    }
    
    func testTest() {
        firstly(execute: loginTeachSite)
            .then(execute: gotoTestPage)
            .catch { error in
                print(error)
            }
    }
}

//校园门户信息，可以通过外网访问
//http://portal.dlut.edu.cn/

//登录校园门户，需要跳转几次
extension DUTInfo {
    //打开登录链接
    //因为每次打开都会生成一个登录用的ID，所以要特意打开这个链接
    fileprivate func getLoginPortalURL() -> URLDataPromise {
        let url = URL(string: "http://portal.dlut.edu.cn/cas/login?service=http%3A%2F%2Fportal.dlut.edu.cn%2Fcas.jsp")
        let request = URLRequest(url: url!)
        return URLSession.shared.dataTask(with: request)
    }
    
    //获取登录用的"lt"字符串，之后登录
    fileprivate func gotoPortal(_ data: Data) -> URLDataPromise {
        let requestStr = utf8String(fromGBKData: data)
        let pharseStr = try! HTMLDocument(string: requestStr)
        let ltID = pharseStr.body?
                .children[0].children[5].children[0].children[0]
                .children[1].children[0].children[1].children[1]
                .children[1].children[1].children[1].attr("value")
        let url = URL(string: "http://portal.dlut.edu.cn/cas/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = ("encodedService=http%253a%252f%252fportal.dlut.edu.cn%252fcas.jsp&service=http%3A%2F%2Fportal.dlut.edu.cn%2Fcas.jsp&serviceName=null&action=DCPLogin&inputname=" + studentNumber + "&selmail=1&username=" + studentNumber + "&password=" + portalPassword + "&lt=" + ltID! + "&userNameType=cardID&Submit=%B5%C7%C2%BC")
            .data(using: .utf8)
        return URLSession.shared.dataTask(with: request)
    }
    
    //得到校园门户主页的URL，后面查课程表和成绩会用到
    fileprivate func gotoPortalMainPage(_ data: Data) -> URLDataPromise {
        let requestStr = utf8String(fromGBKData: data)
        let pharseStr = try! HTMLDocument(string: requestStr)
        let urlStr = pharseStr.body?
                    .children[0].children[0].children[0].attr("href")
        let url = URL(string: urlStr!)!
        let request = URLRequest(url: url)
        return URLSession.shared.dataTask(with: request)
    }
    
    fileprivate func portalPrint(_ data: Data) {
        let str = String(data: data, encoding: .utf8)
        print(str!)
    }
    
    func portalTest() {
        firstly(execute: getLoginPortalURL)
              .then(execute: gotoPortal)
              .then(execute: gotoPortalMainPage)
              .then(execute: portalPrint)
              .catch { error in
                print(error)
            }
    }
}

//校园卡余额及电子支付余额信息
extension DUTInfo {
    fileprivate func getEcardURL(_ data: Data) -> URLDataPromise {
        let url = URL(string: "http://portal.dlut.edu.cn/eapdomain/neudcp/sso/ecard_query_new.jsp")!
        let request = URLRequest(url: url)
        return URLSession.shared.dataTask(with: request)
    }
    
    //这个页面要跳转一下……
    fileprivate func gotoEcardPage(_ data: Data) -> URLDataPromise {
        let requestStr = utf8String(fromGBKData: data)
        let pharseStr = try! HTMLDocument(string: requestStr)
        let urlStr = pharseStr.body?
                    .children[0].children[0].children[0].attr("href")
        let url = URL(string: urlStr!)!
        let request = URLRequest(url: url)
        return URLSession.shared.dataTask(with: request)
    }
    
    fileprivate func getEcardInfo(_ data: Data) {
        let parseStr = try! HTMLDocument(data: data)
        let ecardMoney = parseStr.body?
                        .children[0].children[0].children[2].children[0]
                        .children[0].stringValue
        let eMoney = parseStr.body?
                    .children[0].children[1].children[1].children[0]
                    .children[0].stringValue
        print("玉兰卡余额：" + ecardMoney! + "元")
        print("电子支付账户余额：" + eMoney! + "元")
        ecardCost = ecardMoney! + "元"
    }
    
    func ecardInfo(handle: @escaping (Void) -> Void) {
        firstly(execute: getLoginPortalURL)
            .then(execute: gotoPortal)
            .then(execute: getEcardURL)
            .then(execute: gotoEcardPage)
            .then(execute: getEcardInfo)
            .then(execute: handle)
            .catch { error in
                print(error)
        }
    }
}

//课程表信息
//之所以要一个个界面跳转是因为URL中TM中有上一个界面中的标识ID
extension DUTInfo {
    //前往“个人信息"界面
    fileprivate func gotoMyInfoPage(_ data: Data) -> URLDataPromise {
        let parseStr = try! HTMLDocument(data: data)
        let urlStr = parseStr.body?
                    .children[0].children[23].children[0].children[0]
                    .children[0].children[0].children[0].children[0]
                    .children[11].children[0].attr("href")
        let url = URL(string: urlStr!)!
        let request = URLRequest(url: url)
        return URLSession.shared.dataTask(with: request)
    }
    
    //准备前往"我的教务信息界面"，相当于点了一下"我的教务信息"按钮
    fileprivate func clickMyTeachButton(_ data: Data) -> URLDataPromise {
        let parseStr = try! HTMLDocument(data: data)
        let urlStr = parseStr.body?
                    .children[0].children[23].children[1].children[0]
                    .children[0].children[0].children[0].children[2]
                    .children[2].children[0].children[0].children[1]
                    .children[0].attr("href")
        let url = URL(string: urlStr!)!
        let request = URLRequest(url: url)
        return URLSession.shared.dataTask(with: request)
    }
    
    //"我的教务信息界面要进行一次跳转……"
    fileprivate func getMyTeachURL(_ data: Data) -> URLDataPromise {
        let parseStr = try! HTMLDocument(data: data)
        let str = parseStr.body?
                  .children[0].children[23].children[1].children[0]
                  .children[2].children[0].children[0].children[0]
                  .children[0].children[0].children[1].children[0]
                  .children[1].children[0].attr("src")
        let url = URL(string: "http://portal.dlut.edu.cn" + str!)!
        let request = URLRequest(url: url)
        return URLSession.shared.dataTask(with: request)
    }
    
    //总算进来了
    fileprivate func gotoMyTeachPage(_ data: Data) -> URLDataPromise {
        let requestStr = utf8String(fromGBKData: data)
        let parseStr = try! HTMLDocument(string: requestStr)
        let urlStr = parseStr.body?
                    .children[0].children[0].children[0].attr("href")
        let url = URL(string: urlStr!)!
        let request = URLRequest(url: url)
        return URLSession.shared.dataTask(with: request)
    }
    
    //前往课程表界面
    fileprivate func gotoMySchedulePage(_ data: Data) -> URLDataPromise {
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
        let xq_dummy = "春季学期".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        request.httpBody = ("xn_dummy=2016-2017&xq_dummy="
                            + xq_dummy
                            + "&reportId="
                            + reportID
                            + "&newReport=true&xn=2016-2017&xq=2").data(using: .utf8)
        return URLSession.shared.dataTask(with: request)
    }
    
    fileprivate func getSchedule(_ data: Data) {
        let parseStr = try! HTMLDocument(data: data)
        let courses = parseStr.body?
                .children[1].children[1].children[0].children[0]
                .children[0].children[0].children[0].children[0]
                .children[0].children[0].children[0].children
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
                print(courseInfo[1].stringValue)
                print(courseInfo[8].stringValue)
                print(courseInfo[5].stringValue)
                print(courseInfo[6].stringValue)
                print(courseInfo[7].stringValue)
            } else {
                print(courseInfo[2].stringValue)
                print(courseInfo[3].stringValue)
                print(courseInfo[4].stringValue)
            }
        }
    }
    
    fileprivate func schedulePrint(_ data: Data) {
        let str = String(data: data, encoding: .utf8)
        print(str!)
    }
    
    func scheduleInfo() {
        firstly(execute: getLoginPortalURL)
            .then(execute: gotoPortal)
            .then(execute: gotoPortalMainPage)
            .then(execute: gotoMyInfoPage)
            .then(execute: clickMyTeachButton)
            .then(execute: getMyTeachURL)
            .then(execute: gotoMyTeachPage)
            .then(execute: gotoMySchedulePage)
            .then(execute: getSchedule)
            .catch { error in
                print(error)
            }
    }
}

//校园网信息，只能在校园网环境下访问
//http://tulip.dlut.edu.cn
extension DUTInfo {
    fileprivate func gotoNetPage() -> URLDataPromise {
        //需要在URL中加入时间戳参数
        let timeInterval = Date().timeIntervalSince1970
        let urlStr = "http://tulip.dlut.edu.cn/rpc?tm=\(Int(timeInterval))"
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        //将POST内容类型设置为json
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"jsonrpc\":\"2.0\",\"method\":\"/dllg/login/prepareLogin\",\"id\":\"1\",\"params\":[\"\(studentNumber!)\",\"\(portalPassword!)\",false]}".data(using: .utf8)
        return URLSession.shared.dataTask(with: request)
    }
    
    fileprivate func getNetID(_ data: Data) -> Promise<String> {
        //返回数据为json格式，解析后是一个字典
        let parseDic = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                        as! [String: Any]
        let array = parseDic["result"] as! [Any]
        let dictionary = array[0] as! [String: Any]
        //从一层一层的字典里取到用户的ID，用于之后的查询
        let id = dictionary["ID"] as! Int
        return Promise(value: "\(id)")
    }
    
    fileprivate func requestNetMoney(_ id: String) -> URLDataPromise {
        let timeInterval = Date().timeIntervalSince1970
        let urlStr = "http://tulip.dlut.edu.cn/rpc?tm=\(Int(timeInterval))"
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "[{\"jsonrpc\":\"2.0\",\"method\":\"/asset/asset/getById\",\"id\":\"1\",\"params\":[\"User\",\(id)]},{\"jsonrpc\":\"2.0\",\"method\":\"/user/charge/getChargeInfo\",\"id\":\"2\",\"params\":[\(id)]}]".data(using: .utf8)
        return URLSession.shared.dataTask(with: request)
    }
    
    fileprivate func getNetMoney(_ data: Data) -> Promise<String> {
        let parseArray = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                          as! [Any]
        //先取得余额和已使用金额用于输出
        let dictionary = parseArray[1] as! [String: Any]
        let subDictionary = dictionary["result"] as! [String: Any]
        //余额
        let balance = subDictionary["balance"] as! Double
        //已使用
        let expenditure = subDictionary["expenditure"] as! Double
        print("余额为：\(balance)元")
        netCost = "\(balance)元"
        print("已使用： \(expenditure)元")
        //再取得ID用于下一步的其他查询
        let idDictionary = parseArray[0] as! [String: Any]
        let idSubDictionary = idDictionary["result"] as! [String: Any]
        let id = idSubDictionary["ID"] as! Int
        return Promise(value: "\(id)")
    }
    
    fileprivate func requestNetIP(_ id: String) -> URLDataPromise {
        let timeInterval = Date().timeIntervalSince1970
        let urlStr = "http://tulip.dlut.edu.cn/rpc?tm=\(Int(timeInterval))"
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"jsonrpc\":\"2.0\",\"method\":\"/user/service/list\",\"id\":\"1\",\"params\":[\"StaticNetwork\",\"\(id)\",{}]}".data(using: .utf8)
        return URLSession.shared.dataTask(with: request)
    }
    
    fileprivate func getNetIp(_ data: Data) -> Promise<String> {
        let pharseDic = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            as! [String: Any]
        let array = pharseDic["result"] as! [Any]
        let dictionary = array[0] as! [String: Any]
        let mac = dictionary["MAC"] as! String
        let ip = dictionary["IP"] as! String
        print("IP为：" + ip)
        print("MAC为：" + mac)
        return Promise(value: ip)
    }
    
    fileprivate func requestNetFlow(_ ip: String) -> URLDataPromise {
        let timeInterval = Date().timeIntervalSince1970
        let urlStr = "http://tulip.dlut.edu.cn/rpc?tm=\(Int(timeInterval))"
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        //"\\u670d\\u52a1"为"余额"两字，已转为HTTP格式的转义字符
        request.httpBody = "{\"jsonrpc\":\"2.0\",\"method\":\"/dllg/network/dayFlowRecords\",\"params\":[{\"pageIndex\":\"1\",\"pageSize\":\"10\",\"filter\":{\"fromDate\":\"2017-07-01 00:00:00\",\"toDate\":\"2017-07-31 23:59:59\",\"accountId\":\"\(studentNumber!)\",\"businessInstanceName\":\"\(ip)\",\"businessTypeName\":\"IP\\u670d\\u52a1\"}}],\"id\":\"1\"}".data(using: .utf8)
        return URLSession.shared.dataTask(with: request)
    }
    
    fileprivate func getNetFlow(_ data: Data) {
        let pharseDic = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                        as! [String: Any]
        let dictionary = pharseDic["result"] as! [String: Any]
        let array = dictionary["data"] as! [Any]
        let subDictionary = array[0] as! [String: Any]
        let remainFreeFlow = subDictionary["remainFreeFlow"] as! Double
        print("剩余流量：\(remainFreeFlow)MB")
        netFlow = "\(Int(remainFreeFlow))MB"
    }
    
    func netInfo(handle: @escaping (Void) -> Void) {
        firstly(execute: gotoNetPage)
            .then(execute: getNetID)
            .then(execute: requestNetMoney)
            .then(execute: getNetMoney)
            .then(execute: requestNetIP)
            .then(execute: getNetIp)
            .then(execute: requestNetFlow)
            .then(execute: getNetFlow)
            .then(execute: handle)
            .catch { error in
                print(error)
            }
    }
}
