//
//  TodayViewController.swift
//  DUTInformationToday
//
//  Created by shino on 2017/7/9.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var netFlowLabel: UILabel!
    @IBOutlet weak var netCostLabel: UILabel!
    @IBOutlet weak var ecardCostLabel: UILabel!
    
    var dutInfo: DUTInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dutInfo = DUTInfo()
        dutInfo.studentNumber = "201487033"
        dutInfo.teachPassword = "220317"
        dutInfo.portalPassword = "shino$sshLoca1"
    }
    
    @IBAction func freshInfo() {
        dutInfo.ecardInfo() {
            DispatchQueue.main.async {
                self.ecardCostLabel.text = self.dutInfo.ecardCost
            }
        }
        dutInfo.netInfo {
            DispatchQueue.main.async {
                self.netCostLabel.text = self.dutInfo.netCost
                self.netFlowLabel.text = self.dutInfo.netFlow
            }
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        print("1")
        completionHandler(NCUpdateResult.newData)
    }
    
}
