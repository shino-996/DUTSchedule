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
    lazy var dutInfo = DUTInfo()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dutInfo.loginPortalSite(failed: {
            self.performSegue(withIdentifier: "LoginTeach", sender: self)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginTeach" {
            let navigation = segue.destination as! UINavigationController
            let destination = navigation.topViewController as! LoginTeachSiteViewController
            destination.dutInfo = dutInfo
        } else {
            fatalError()
        }
    }
    
    @IBAction func loadSchedule() {
        self.dutInfo.scheduleInfo()
        activityIndicator.startAnimating()
    }
}
