//
//  ViewController.swift
//  DUTInfomation
//
//  Created by shino on 2017/7/3.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DUTInfoDelegate {
    var dutInfo: DUTInfo!

    override func viewDidLoad() {
        super.viewDidLoad()
        dutInfo = DUTInfo(studentNumber: "学号", teachPassword: "教务处密码", portalPassword: "校园门户密码")
        dutInfo.delegate = self
        dutInfo.newPortalNetInfo()
        dutInfo.scheduleInfo()
    }
    
    func setNetCost(_ netCost: String) {
        print(netCost)
    }
    
    func setNetFlow(_ netFlow: String) {
        print(netFlow)
    }
    
    func setEcardCost(_ ecardCost: String) {
        print(ecardCost)
    }
    
    func setSchedule(_ courseArray: [[String : String]]) {
        print(courseArray)
    }
    
    func netErrorHandle() {
    }
}

