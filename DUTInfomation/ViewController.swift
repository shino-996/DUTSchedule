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
    
    @IBOutlet weak var netCostLabel: UILabel!
    @IBOutlet weak var netFlowLabel: UILabel!
    @IBOutlet weak var ecardCostLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        dutInfo = DUTInfo()
        dutInfo.delegate = self
        dutInfo.studentNumber = "201487033"
        dutInfo.teachPassword = "220317"
        dutInfo.portalPassword = "shino$sshLoca1"
        dutInfo.ecardInfo()
        dutInfo.netInfo()
    }
    
    func setEcardCost() {
        DispatchQueue.main.async {
            self.ecardCostLabel.text = self.dutInfo.ecardCost
            let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
            userDefaults.set(self.dutInfo.ecardCost, forKey: "EcardCost")
        }
    }
    
    func setNetCost() {
        DispatchQueue.main.async {
            self.netCostLabel.text = self.dutInfo.netCost
            let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
            userDefaults.set(self.dutInfo.netCost, forKey: "NetCost")
            userDefaults.set(false, forKey: "IsNetError")
        }
    }
    
    func setNetFlow() {
        DispatchQueue.main.async {
            self.netFlowLabel.text = self.dutInfo.netFlow
            let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
            userDefaults.set(self.dutInfo.netFlow, forKey: "NetFlow")
            userDefaults.set(false, forKey: "IsNetError")
        }
    }
    
    func netErrorHandle() {
        UserDefaults(suiteName: "group.dutinfo.shino.space")?.set(true, forKey: "IsNetError")
    }
}
