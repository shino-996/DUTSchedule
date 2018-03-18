//
//  LoginTeachSiteViewController.swift
//  DUTInfomation
//
//  Created by shino on 2017/9/7.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit
import DUTInfo

class LoginTeachSiteViewController: UIViewController {
    @IBOutlet weak var studentNumber: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginFailedLabel: UILabel!
    
    var dutInfo: DUTInfo!
    var didLogHandler: (() -> Void)?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginPortal" {
            let destination = segue.destination as! LoginPortalSiteViewController
            destination.number = studentNumber.text
            destination.teachPassword = password.text
            destination.dutInfo = dutInfo
            destination.didLogHandler = didLogHandler
        } else {
            fatalError()
        }
    }
    
    @IBAction func LoginTeachSite() {
        dutInfo = DUTInfo(studentNumber: studentNumber.text ?? "",
                          teachPassword: password.text ?? "",
                          portalPassword: "")
        if dutInfo.loginTeachSite() {
            performSegue(withIdentifier: "LoginPortal", sender: self)
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
