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
    var didLogHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentNumber.text = number
    }
    
    @IBAction func LoginPortalSite() {
        dutInfo = DUTInfo(studentNumber: studentNumber.text ?? "",
                          password: password.text ?? "",
                          fetches: [])
        if dutInfo.login() {
            let studentNumber = number!
            KeyInfo.shared.setAccount((studentNumber, teachPassword, password.text!))
            self.didLogHandler?()
            self.navigationController?.dismiss(animated: true)
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
