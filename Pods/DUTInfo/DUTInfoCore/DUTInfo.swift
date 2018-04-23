//
//  TeachInfo.swift
//  DUTInfo
//
//  Created by shino on 2017/7/3.
//  Copyright © 2017年 shino. All rights reserved.
//

import PromiseKit
import Fuzi
import Foundation

//可能会遇到的错误类型
public enum DUTError: Error {
    case authError
    case evaluateError
    case netError
    case otherError
}

typealias Rsp = (data: Data, response: URLResponse)

public class DUTInfo: NSObject {
    //学号
    public var studentNumber: String
    //教务处密码，默认为身份证号后6位
    public var teachPassword: String
    //校园门户密码，默认为身份证号后6位
    public var portalPassword: String
    
    //用于网络请求的session
    //新版校园门户
    var portalSession: URLSession!
    //教务处
    var teachSession: URLSession!
    
    public init(studentNumber: String = "",
                teachPassword: String = "",
                portalPassword: String = "") {
        self.studentNumber = studentNumber
        self.teachPassword = teachPassword
        self.portalPassword = portalPassword
    }
}
