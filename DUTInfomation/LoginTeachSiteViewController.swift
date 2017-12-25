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
    
    var dutInfo: DUTInfo!
    var loginHandler: (() -> Void)?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginPortal" {
            let destination = segue.destination as! LoginPortalSiteViewController
            destination.dutInfo = dutInfo
            destination.number = studentNumber.text
            destination.teachPassword = password.text
            destination.loginHandler = loginHandler
        } else {
            fatalError()
        }
    }
    
    @IBAction func LoginTeachSite() {
        dutInfo.studentNumber = studentNumber.text ?? ""
        dutInfo.teachPassword = password.text ?? ""
        dutInfo.loginTeachSite(succeed: loginSucceed, failed: loginFailed)
    }
    
    func loginSucceed() {
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
