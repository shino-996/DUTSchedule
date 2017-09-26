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

protocol DUTInfoDelegate {
    //当DUTInfo属性更改时会调用的委托方法
    func setNetCost(_ netCost: String)
    func setNetFlow(_ netFlow: String)
    func setEcardCost(_ ecardCost: String)
    func setSchedule(_ courseArray: [[String: String]])
    
    //当网络异常时会调用的委托方法
    func netErrorHandle()
}

//可能会遇到的错误类型
enum DUTError: Error {
    case authError
}

class DUTInfo: NSObject {
    //学号
    var studentNumber: String
    //教务处密码，默认为身份证号后6位
    var teachPassword: String
    //校园门户密码，默认为身份证号后6位
    var portalPassword: String

    //用于网络请求的session
    //旧版校园门户
    var portalSession: URLSession!
    //新版校园门户
    var newPortalSession: URLSession!
    //教务处
    var teachSession: URLSession!
    // 校园网
    var netSession: URLSession!
    
    //委托对象，用于属性更新时的回调
    var delegate: DUTInfoDelegate!
        
    override init() {
        studentNumber = ""
        teachPassword = ""
        portalPassword = ""
    }
    
    init(studentNumber: String, teachPassword: String, portalPassword: String) {
        self.studentNumber = studentNumber
        self.teachPassword = teachPassword
        self.portalPassword = portalPassword
    }
    
    var netCost: String! {
        didSet {
            delegate.setNetCost(netCost)
        }
    }
    var netFlow: String! {
        didSet {

            delegate.setNetFlow(netFlow)
        }
    }
    var ecardCost: String! {
        didSet {
            delegate.setEcardCost(ecardCost)
        }
    }
    
    func login(succeed: @escaping () -> Void = {}, failed: @escaping () -> Void = {}) {
        loginTeachSite(succeed: {
            self.loginPortalSite(succeed: succeed, failed: failed)
        }, failed: failed)
    }
}
