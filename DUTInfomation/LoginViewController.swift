//
//  LoginViewController.swift
//  DUTInfomation
//
//  Created by shino on 2017/9/7.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var studentNumber: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginFailedLabel: UILabel!
    
    @IBAction func LoginTeachSite() {
        let usr = studentNumber.text ?? ""
        let pwd = password.text ?? ""
        if NetRequest.shared.auth(studentNumber: usr, password: pwd) {
            UserInfo.shared.setAccount(studentNumber: usr,
                                      password: pwd)
            self.dismiss(animated: true)
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "space.shino.post.loged")))
        } else {
            self.loginFailedLabel.isHidden = false
        }
    }
    
    @IBAction func tapSpace(_ sender: Any) {
        view.endEditing(true)
    }
}

extension LoginViewController: UITextFieldDelegate {
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
