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
    static let shared = KeyInfo()
    
    private let service = "DUTInfomation"
    private let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
    
    //姓名和学号保存在userefaults中, 以[[name: "XXX", number: "xxxxxxxxx"]]字典数组形式保存
    func setAccount(_ account: (studentNumber: String, teachPassword: String, portalPassowrd: String)) {
        if let previousStudentNumber = userDefaults.string(forKey: "studentnumber") {
            if previousStudentNumber == account.studentNumber {
                updatePassword(studentNumber: account.studentNumber,
                               teachPassword: account.teachPassword,
                               portalPassword: account.portalPassowrd)
                return
            } else {
                removePasword(ofStudentnumber: previousStudentNumber)
                userDefaults.set(account.studentNumber, forKey: "studentnumber")
                savePassword(studentNumber: account.studentNumber,
                             teachPassword: account.teachPassword,
                             portalPassword: account.portalPassowrd)
            }
        } else {
            userDefaults.set(account.studentNumber, forKey: "studentnumber")
            savePassword(studentNumber: account.studentNumber,
                         teachPassword: account.teachPassword,
                         portalPassword: account.portalPassowrd)
        }
    }
    
    func getAccount() -> (studentNumber: String, teachPassword: String, portalPassword: String)? {
        guard let studentNumber = userDefaults.string(forKey: "studentnumber") else {
            return nil
        }
        let (teachPassword, portalPassword) = loadPassword(studentNumber: studentNumber)
        return (studentNumber, teachPassword, portalPassword)
    }
    
    func removeAccount() {
        guard let studentNumber = userDefaults.string(forKey: "studentnumber") else {
            return
        }
        removePasword(ofStudentnumber: studentNumber)
        userDefaults.removeObject(forKey: "studentnumber")
    }
    
    //以学号作为主键将教务处密码和校园门户保存在keychain中, 以逗号为间隔只保存为一个字段
    private func savePassword(studentNumber: String, teachPassword: String, portalPassword: String) {
        let password = teachPassword + ", " + portalPassword
        let searchKeychainQuery = [kSecClass: kSecClassGenericPassword,
                                   kSecAttrService: service,
                                   kSecAttrAccount: studentNumber,
                                   kSecReturnData: kCFBooleanTrue,
                                   kSecMatchLimit: kSecMatchLimitOne] as CFDictionary
        var dataTyperef: AnyObject?
        let searchStatus = SecItemCopyMatching(searchKeychainQuery, &dataTyperef)
        guard searchStatus != errSecSuccess else {
            self.updatePassword(studentNumber: studentNumber, teachPassword: teachPassword, portalPassword: portalPassword)
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
    
    private func loadPassword(studentNumber: String) -> (teachPassword: String, portalPassword: String) {
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
    
    private func updatePassword(studentNumber: String, teachPassword: String, portalPassword: String) {
        let password = teachPassword + ", " + portalPassword
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
