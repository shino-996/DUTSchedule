//
//  KeyInfo.swift
//  DUTInfomation
//
//  Created by shino on 23/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import Foundation
import Security

let kSecClassValue = NSString(format: kSecClass)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecAttrServiceValue = NSString(format: kSecAttrService)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)
let kSecAttrAccessGroupValue = NSString(format: kSecAttrAccessGroup)

struct KeyInfo {
    private let service = "DUTInfomation"
    var account: String
    
    init?() {
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        guard let account = userDefaults.string(forKey: "account") else {
            return nil
        }
        self.account = account
    }
    
    init(account: String) {
        self.account = account
    }
    
    func savePassword(teachPassword: String, portalPassword: String) {
        let password = teachPassword + ", " + portalPassword
        let data = password.data(using: .utf8)!
        let keychainQuery = [kSecClassValue: kSecClassGenericPasswordValue,
                             kSecAttrServiceValue: service,
                             kSecAttrAccountValue: account,
                             kSecValueDataValue: data] as CFDictionary
        let status = SecItemAdd(keychainQuery, nil)
        if status != errSecSuccess {
            print(status)
        }
    }
    
    func loadPassword() -> (teachPassword: String, portalPassword: String) {
        let keychainQuery = [kSecClassValue: kSecClassGenericPasswordValue,
                             kSecAttrServiceValue: service,
                             kSecAttrAccountValue: account,
                             kSecReturnDataValue: kCFBooleanTrue,
                             kSecMatchLimitValue: kSecMatchLimitOneValue] as CFDictionary
        var dataTyperef: AnyObject?
        let status = SecItemCopyMatching(keychainQuery, &dataTyperef)
        if status != errSecSuccess {
            print(status)
        }
//        var contentOfKeychain: (String, String)
//        if status == errSecSuccess {
//            if let receiveData = dataTyperef as? Data {
//                let passwordString = String(data: receiveData, encoding: .utf8)!
//                                    .components(separatedBy: ", ")
//                contentOfKeychain = (passwordString[0], passwordString[1])
//            }
//        } else {
//            print(status)
//        }
//        return contentOfKeychain
        let receiveData = dataTyperef as! Data
        let passwordString = String(data: receiveData, encoding: .utf8)!.components(separatedBy: ", ")
        return (passwordString[0], passwordString[1])
        
    }
    
    func removePasword() {
        let keychainQuery = [kSecClassValue: kSecClassGenericPasswordValue,
                             kSecAttrServiceValue: service,
                             kSecAttrAccountValue: account,
                             kSecReturnDataValue: kCFBooleanTrue,
                             kSecMatchLimitValue: kSecMatchLimitOneValue] as CFDictionary
        let status = SecItemDelete(keychainQuery)
        if status != errSecSuccess {
            print(status)
        }
    }
    
    func updatePassword(password: String) {
        let data = password.data(using: .utf8, allowLossyConversion: false)!
        let keychainQuery = [kSecClassValue: kSecClassGenericPasswordValue,
                             kSecAttrServiceValue: service,
                             kSecAttrAccountValue: account,
                             kSecReturnDataValue: kCFBooleanTrue,
                             kSecMatchLimitValue: kSecMatchLimitOneValue] as CFDictionary
        let status = SecItemUpdate(keychainQuery, [kSecValueDataValue: data] as CFDictionary)
        if status != errSecSuccess {
            print(status)
        }
    }
}
