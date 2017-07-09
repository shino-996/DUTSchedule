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
    
    @IBOutlet weak var netCostLabel: UILabel!
    @IBOutlet weak var netFlowLabel: UILabel!
    @IBOutlet weak var ecardCostLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        dutInfo = DUTInfo()
        dutInfo.studentNumber = "201487033"
        dutInfo.teachPassword = "220317"
        dutInfo.portalPassword = "shino$sshLoca1"
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
}
