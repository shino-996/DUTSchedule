//
//  KeyInfo.swift
//  DUTInfomation
//
//  Created by shino on 23/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import Foundation
import Security

struct KeyInfo {
    static let service = "DUTInfomation"
    
    static func getAccounts() -> [String]? {
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        guard let accounts = userDefaults.array(forKey: "accounts") as? [String] else {
            return nil
        }
        return accounts
    }
    
    static func getCurrentAccount() -> String? {
        guard let accounts = getAccounts() else {
            return nil
        }
        return accounts.last
    }
    
    static func updateAccounts(accounts: [String]) {
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        userDefaults.set(accounts, forKey: "accounts")
    }
    
    static func savePassword(studentNumber: String, teachPassword: String, portalPassword: String) {
        let password = teachPassword + ", " + portalPassword
        let data = password.data(using: .utf8)!
        let keychainQuery = [kSecClass: kSecClassGenericPassword,
                             kSecAttrService: service,
                             kSecAttrAccount: studentNumber,
                             kSecValueData: data] as CFDictionary
        let status = SecItemAdd(keychainQuery, nil)
        if status != errSecSuccess {
            print(status)
            fatalError()
        }
    }
    
    static func loadPassword(studentNumber: String) -> (teachPassword: String, portalPassword: String) {
        let keychainQuery = [kSecClass: kSecClassGenericPassword,
                             kSecAttrService: service,
                             kSecAttrAccount: studentNumber,
                             kSecReturnData: kCFBooleanTrue,
                             kSecMatchLimit: kSecMatchLimitOne] as CFDictionary
        var dataTyperef: AnyObject?
        let status = SecItemCopyMatching(keychainQuery, &dataTyperef)
        if status != errSecSuccess {
            print(status)
            fatalError()
        }
        let receiveData = dataTyperef as! Data
        let passwordString = String(data: receiveData, encoding: .utf8)!.components(separatedBy: ", ")
        return (passwordString[0], passwordString[1])
        
    }
    
    static func removePasword(ofStudentnumber studentNumber: String) {
        let keychainQuery = [kSecClass: kSecClassGenericPassword,
                             kSecAttrService: service,
                             kSecAttrAccount: studentNumber] as CFDictionary
        let status = SecItemDelete(keychainQuery)
        if status != errSecSuccess {
            print(status)
            fatalError()
        }
    }
    
    static func updatePassword(studentNumber: String, teachPassword: String, portalPassword: String) {
        let password = teachPassword + ", " + portalPassword
        let data = password.data(using: .utf8)!
        let keychainQuery = [kSecClass: kSecClassGenericPassword,
                             kSecAttrService: service,
                             kSecAttrAccount: studentNumber,
                             kSecReturnData: kCFBooleanTrue,
                             kSecMatchLimit: kSecMatchLimitOne] as CFDictionary
        let status = SecItemUpdate(keychainQuery, [kSecValueData: data] as CFDictionary)
        if status != errSecSuccess {
            print(status)
            fatalError()
        }
    }
}
