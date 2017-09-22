//
//  LoginTeachSiteViewController.swift
//  DUTInfomation
//
//  Created by shino on 2017/9/7.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit

class LoginTeachSiteViewController: UIViewController {
    @IBOutlet weak var studentNumber: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginFailedLabel: UILabel!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! LoginPortalSiteViewController
        destination.number = studentNumber.text
    }
    
    @IBAction func LoginTeachSite() {
        let dutInfo = DUTInfo(studentNumber.text ?? "", password.text ?? "")
        dutInfo.loginTeachSite(succeed: loginSucceed, failed: loginFailed)
    }
    
    func loginSucceed() {
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        userDefaults.set(studentNumber.text!, forKey: "StudentNumber")
        userDefaults.set(password.text!, forKey: "TeachPassword")
        performSegue(withIdentifier: "LoginPortal", sender: self)
    }
    
    func loginFailed() {
        DispatchQueue.main.async {
            self.loginFailedLabel.isHidden = false
        }
    }
    
    @IBAction func tapSpace(_ sender: Any) {
        view.endEditing(true)
    }
}

extension LoginTeachSiteViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == studentNumber {
            return password.becomeFirstResponder()
        } else if textField == password {
            return textField.resignFirstResponder()
        } else {
            return false
        }
    }
}
