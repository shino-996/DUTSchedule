//
//  DutInfoTeachSite.swift
//  DUTInfomation
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
extension DUTInfo {
    private func gotoTeachPage() -> URLDataPromise {
        let url = URL(string: "http://zhjw.dlut.edu.cn/loginAction.do")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = ("zjh=" + self.studentNumber + "&mm=" + self.teachPassword)
            .data(using: String.Encoding.utf8)
        return URLSession.shared.dataTask(with: request)
    }
    
    //验证是否登录成功
    private func teachLoginVerify(_ data: Data) throws -> Bool {
        let requestStr = data.unicodeString
        let parseStr = try! HTMLDocument(string: requestStr)
        let verifyStr = parseStr.title
        if verifyStr! != "学分制综合教务" {
            throw DUTError.authError
        }
        return true
    }
    
    private func teachErrorHandle(_ error: Error) {
        if let error = error as? DUTError {
            if error == .authError {
                print("教务处用户名或密码错误！")
            }
        } else {
            print(error)
        }
    }
    
    func loginTeachSite(succeed: @escaping () -> Void = {}, failed: @escaping () -> Void = {}) {
        firstly(execute: gotoTeachPage)
        .then(execute: teachLoginVerify)
        .then { (ifLogin: Bool) -> Void in
            if ifLogin {
                succeed()
            }
        }.catch { _ in
            failed()
        }
        .catch(execute: teachErrorHandle)
    }
    
    //查询本学期成绩
    //进入本学期成绩界面
    private func gotoGradePage(_: Bool) -> URLDataPromise {
        let url = URL(string: "http://zhjw.dlut.edu.cn/bxqcjcxAction.do")!
        let request = URLRequest(url: url)
        return URLSession.shared.dataTask(with: request)
    }
    
    //解析出各科成绩
    private func getGrade(_ data: Data) {
        let requestString = data.unicodeString
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
        firstly(execute: gotoTeachPage)
            .then(execute: teachLoginVerify)
            .then(execute: gotoGradePage)
            .then(execute: getGrade)
            .catch(execute: teachErrorHandle)
    }
    
    //查询考试安排
    //因为我小学期没有考试……等抓到有考试的人再用他的账号抓吧【
    private func gotoTestPage(_: Bool) -> URLDataPromise {
        let url = URL(string: "http://zhjw.dlut.edu.cn/ksApCxAction.do?oper=getKsapXx")!
        let request = URLRequest(url: url)
        return URLSession.shared.dataTask(with: request)
    }
    
    private func testPrint(_ data: Data) {
        let str = data.unicodeString
        print(str)
    }
    
    func testInfo() {
        firstly(execute: gotoTeachPage)
            .then(execute: teachLoginVerify)
            .then(execute: gotoTestPage)
            .then(execute: testPrint)
            .catch(execute: teachErrorHandle)
    }
}
