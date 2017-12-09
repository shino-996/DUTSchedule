//
//  ViewController.swift
//  DUTInfomation
//
//  Created by shino on 2017/7/3.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit

class CostViewController: UIViewController, DUTInfoDelegate {
    @IBOutlet weak var netCostLabel: UILabel!
    @IBOutlet weak var netFlowLabel: UILabel!
    @IBOutlet weak var ecardCostLabel: UILabel!
    
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
        dutInfo.loginNewPortalSite(succeed: {
            self.dutInfo.newPortalNetInfo()
        }, failed: {
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
    
    func setEcardCost(_ ecardCost: String) {
        DispatchQueue.main.async {
            self.ecardCostLabel.text = ecardCost
        }
    }
    
    func setNetCost(_ netCost: String) {
        DispatchQueue.main.async {
            self.netCostLabel.text = netCost
        }
    }
    
    func setNetFlow(_ netFlow: String) {
        DispatchQueue.main.async {
            self.netFlowLabel.text = netFlow
        }
    }
    
    func netErrorHandle() {}
    
    func setSchedule(_ courseArray: [[String : String]]) {}
}
