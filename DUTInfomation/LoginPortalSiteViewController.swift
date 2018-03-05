//
//  LoginPortalSiteViewController.swift
//  DUTInfomation
//
//  Created by shino on 2017/9/7.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit
import DUTInfo

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
        if dutInfo.loginPortal() {
            let studentNumber = number!
            KeyInfo.savePassword(studentNumber: studentNumber,
                                 teachPassword: teachPassword,
                                 portalPassword: password.text!)
            var accounts = KeyInfo.getAccounts() ?? [[String: String]]()
            accounts.append(["name": "XXX", "number": studentNumber])
            KeyInfo.updateAccounts(accounts: accounts)
            self.navigationController?.dismiss(animated: true, completion: loginHandler)
        } else {
            DispatchQueue.main.async {
                self.loginFailedLabel.isHidden = false
            }
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
