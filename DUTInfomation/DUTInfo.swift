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
    var studentNumber: String!
    //教务处密码，默认为身份证号后6位
    var teachPassword: String!
    //校园门户密码，默认为身份证号后6位
    var portalPassword: String!
    //用于网络请求的session
    var session: URLSession!
    //委托对象
    var delegate: DUTInfoDelegate!
    
    private override init() {
        super.init()
    }
        
    init?(_: Void) {
        super.init()
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        if let teachPassword = userDefaults.string(forKey: "TeachPassword") {
            studentNumber = userDefaults.string(forKey: "StudentNumber")!
            self.teachPassword = teachPassword
            portalPassword = userDefaults.string(forKey: "PortalPassword")!
        } else {
            return nil
        }
    }
    
    init(_ studentNumber: String, _ teachPassword: String = "", _ portalPassword: String = "") {
        super.init()
        self.studentNumber = studentNumber
        self.teachPassword = teachPassword
        self.portalPassword = portalPassword
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
}
