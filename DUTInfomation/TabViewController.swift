//
//  TabViewController.swift
//  DUTInfomation
//
//  Created by shino on 14/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import UIKit

class TabViewController: UIViewController, DUTInfoDelegate {
    var dutInfo: DUTInfo!
    var loginHandler: (() -> Void)?
    
    func performLogin() {
        performSegue(withIdentifier: "LoginTeach", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginTeach" {
            let navigation = segue.destination as! UINavigationController
            let destination = navigation.topViewController as! LoginTeachSiteViewController
            destination.dutInfo = dutInfo
            destination.loginHandler = loginHandler
        } else {
            fatalError()
        }
    }
    
    func setNetCost(_ netCost: String) {}
    func setNetFlow(_ netFlow: String) {}
    func setEcardCost(_ ecardCost: String) {}
    func setSchedule(_ courseArray: [[String : String]]) {}
    func setTest(_ testArray: [[String : String]]) {}
    func setPersonName(_ personName: String) {}
    func netErrorHandle(_ error: Error) {}
}
