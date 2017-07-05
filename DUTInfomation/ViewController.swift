//
//  ViewController.swift
//  DUTInfomation
//
//  Created by shino on 2017/7/3.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var dutInfo: DUTInfo!

    override func viewDidLoad() {
        super.viewDidLoad()
        dutInfo = DUTInfo()
        dutInfo.studentNumber = "学号"
        dutInfo.teachPassword = "教务处密码"
        dutInfo.portalPassword = "校园门户密码"
        dutInfo.scheduleInfo()
        dutInfo.gradeInfo()
        dutInfo.ecardInfo()
        dutInfo.netInfo()
    }
}

