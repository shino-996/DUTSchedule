//
//  ScheduleViewController.swift
//  DUTInfomation
//
//  Created by shino on 2017/9/13.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var dutInfo: DUTInfo!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if dutInfo == nil {
            dutInfo = DUTInfo(())
        }
        if dutInfo == nil {
            performSegue(withIdentifier: "LoginTeach", sender: self)
        }
    }
    
    @IBAction func loadSchedule() {
        self.dutInfo.scheduleInfo()
        activityIndicator.startAnimating()
    }
}
