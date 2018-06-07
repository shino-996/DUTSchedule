//
//  KeyInfo.swift
//  DUTInfomation
//
//  Created by shino on 23/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import Foundation
import Security

struct UserInfo {
    static let shared = UserInfo()
    
    var isLogin: Bool {
        return getAccount() != nil
    }
    
    private let service = "DUTInfomation"
    private let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
    
    private init() {}
    
    //姓名和学号保存在userefaults中, 以[[name: "XXX", number: "xxxxxxxxx"]]字典数组形式保存
    func setAccount(studentNumber: String, password: String) {
        if let previousStudentNumber = userDefaults.string(forKey: "studentnumber") {
            if previousStudentNumber == studentNumber {
                updatePassword(studentNumber: studentNumber, password: password)
                return
            } else {
                removePasword(ofStudentnumber: previousStudentNumber)
                userDefaults.set(studentNumber, forKey: "studentnumber")
                savePassword(studentNumber: studentNumber, password: password)
            }
        } else {
            userDefaults.set(studentNumber, forKey: "studentnumber")
            savePassword(studentNumber: studentNumber, password: password)
        }
    }
    
    func getAccount() -> (studentNumber: String, password: String)? {
        guard let studentNumber = userDefaults.string(forKey: "studentnumber") else {
            return nil
        }
        let password = loadPassword(studentNumber: studentNumber)
        return (studentNumber, password)
    }
    
    func removeAccount() {
        guard let studentNumber = userDefaults.string(forKey: "studentnumber") else {
            return
        }
        removePasword(ofStudentnumber: studentNumber)
        userDefaults.removeObject(forKey: "studentnumber")
    }
    
    private func savePassword(studentNumber: String, password: String) {
        let searchKeychainQuery = [kSecClass: kSecClassGenericPassword,
                                   kSecAttrService: service,
                                   kSecAttrAccount: studentNumber,
                                   kSecReturnData: kCFBooleanTrue,
                                   kSecMatchLimit: kSecMatchLimitOne] as CFDictionary
        var dataTyperef: AnyObject?
        let searchStatus = SecItemCopyMatching(searchKeychainQuery, &dataTyperef)
        guard searchStatus != errSecSuccess else {
            self.updatePassword(studentNumber: studentNumber, password: password)
            return
        }
        let data = password.data(using: .utf8)!
        let keychainQuery = [kSecClass: kSecClassGenericPassword,
                             kSecAttrService: service,
                             kSecAttrAccount: studentNumber,
                             kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
                             kSecValueData: data] as CFDictionary
        let status = SecItemAdd(keychainQuery, nil)
        if status != errSecSuccess {
            print(status)
            fatalError()
        }
    }
    
    private func loadPassword(studentNumber: String) -> String {
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
        return String(data: receiveData, encoding: .utf8)!
    }
    
    private func removePasword(ofStudentnumber studentNumber: String) {
        let keychainQuery = [kSecClass: kSecClassGenericPassword,
                             kSecAttrService: service,
                             kSecAttrAccount: studentNumber] as CFDictionary
        let status = SecItemDelete(keychainQuery)
        if status != errSecSuccess {
            print(status)
            fatalError()
        }
    }
    
    private func updatePassword(studentNumber: String, password: String) {
        let data = password.data(using: .utf8)!
        let keychainQuery = [kSecClass: kSecClassGenericPassword,
                             kSecAttrService: service,
                             kSecAttrAccount: studentNumber] as CFDictionary
        let status = SecItemUpdate(keychainQuery, [kSecValueData: data] as CFDictionary)
        if status != errSecSuccess {
            print(status)
            fatalError()
        }
    }
}
