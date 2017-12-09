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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if dutInfo == nil {
            let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
            let studentNumber = userDefaults.string(forKey: "StudentNumber")
            let TeachPassword = userDefaults.string(forKey: "TeachPassword")
            let portalPassword = userDefaults.string(forKey: "PortalPassword")
            dutInfo = DUTInfo(studentNumber: studentNumber ?? "",
                              teachPassword: TeachPassword ?? "",
                              portalPassword: portalPassword ?? "")
            dutInfo.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dutInfo.loginNewPortalSite(failed: {
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

extension ScheduleViewController: DUTInfoDelegate {
    func setNetCost(_ netCost: String) {}
    
    func setNetFlow(_ netFlow: String) {}
    
    func setEcardCost(_ ecardCost: String) {}
    
    func setSchedule(_ courseArray: [[String : String]]) {
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")
        let fileURL = groupURL!.appendingPathComponent("course.plist")
        (courseArray as NSArray).write(to: fileURL, atomically: true)
        activityIndicator.stopAnimating()
    }
    
    func netErrorHandle() {}
}
