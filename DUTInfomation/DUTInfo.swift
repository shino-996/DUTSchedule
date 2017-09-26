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
    func setNetCost()
    func setNetFlow()
    func setEcardCost()
    
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
    var session: URLSession!
    
    var newPortalSession: URLSession!
    //委托对象
    var delegate: DUTInfoDelegate!
        
    override init() {
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        studentNumber = userDefaults.string(forKey: "StudentNumber") ?? ""
        teachPassword = userDefaults.string(forKey: "TeachPassword") ?? ""
        portalPassword = userDefaults.string(forKey: "PortalPassword") ?? ""
    }
    
    var netCost: String! {
        didSet {
            delegate.setNetCost()
        }
    }
    var netFlow: String! {
        didSet {
            delegate.setNetFlow()
        }
    }
    var ecardCost: String! {
        didSet {
            delegate.setEcardCost()
        }
    }
    var isScheduleLoaded: Bool! {
        didSet {
            if isScheduleLoaded == true {
                
            }
        }
    }
    
    func login(succeed: @escaping () -> Void = {}, failed: @escaping () -> Void = {}) {
        loginTeachSite(succeed: {
            self.loginPortalSite(succeed: succeed, failed: failed)
        }, failed: failed)
    }
}
