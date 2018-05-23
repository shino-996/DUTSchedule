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
    
    var didLogHandler: (() -> Void)?
    
    @IBAction func LoginTeachSite() {
        let usr = studentNumber.text ?? ""
        let pwd = password.text ?? ""
        let url = URL(string: "https://t.warshiprpg.xyz:88/dut")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = """
            {
            "studentnumber": "\(usr)",
            "password": "\(pwd)",
            "fetch": ["net"]
            }
            """.data(using: .utf8)
        let semaphore = DispatchSemaphore(value: 0)
        var login = false
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                login = false
                print(error)
                return
            }
            login = String(data: data!, encoding: .utf8) != "auth error"
            semaphore.signal()
        }.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        if login {
            KeyInfo.shared.setAccount(studentNumber: studentNumber.text ?? "",
                                      password: password.text ?? "")
            self.didLogHandler?()
            self.dismiss(animated: true)
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
