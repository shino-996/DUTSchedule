//
//  LoginPortalSiteViewController.swift
//  DUTInfomation
//
//  Created by shino on 2017/9/7.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit

class LoginPortalSiteViewController: UIViewController {
    @IBOutlet weak var studentNumber: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginFailedLabel: UILabel!
    
    var dutInfo: DUTInfo!
    var number: String!
    var teachPassword: String!
    var loginHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentNumber.text = number
    }
    
    @IBAction func LoginPortalSite() {
        dutInfo.studentNumber = studentNumber.text ?? ""
        dutInfo.portalPassword = password.text ?? ""
        dutInfo.loginNewPortalSite(succeed: loginSucceed, failed: loginFailed)
    }
    
    func loginSucceed() {
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        userDefaults.set(studentNumber.text!, forKey: "account")
        let keyinfo = KeyInfo(account: studentNumber.text!)
        keyinfo.savePassword(teachPassword: teachPassword, portalPassword: password.text!)
        self.navigationController?.dismiss(animated: true, completion: loginHandler)
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

extension LoginPortalSiteViewController: UITextFieldDelegate {
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
