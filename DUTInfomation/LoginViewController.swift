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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addKeyboardLayoutNotification()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func LoginTeachSite() {
        let usr = studentNumber.text ?? ""
        let pwd = password.text ?? ""
        if NetRequest.shared.auth(studentNumber: usr, password: pwd) {
            UserInfo.shared.setAccount(studentNumber: usr,
                                      password: pwd)
            self.dismiss(animated: true)
            NotificationCenter.default.post(name: "space.shino.post.logined")
        } else {
            self.loginFailedLabel.isHidden = false
        }
    }
}

// 键盘弹出和收回时的布局
extension LoginViewController {
    @IBAction func tapSpace(_ sender: Any) {
        view.endEditing(true)
    }
    
    func addKeyboardLayoutNotification() {
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: nil) { [unowned self] info in
            guard let userInfo = info.userInfo else {
                return
            }
            let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
            self.additionalSafeAreaInsets.bottom = keyboardHeight
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            UIView.animate(withDuration: duration) { [unowned self] in
                self.view.layoutIfNeeded()
            }
        }
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: nil) { [unowned self] info in
            guard let userInfo = info.userInfo else {
                return
            }
            self.additionalSafeAreaInsets.bottom = 0
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            UIView.animate(withDuration: duration) { [unowned self] in
                self.view.layoutIfNeeded()
            }
        }
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
