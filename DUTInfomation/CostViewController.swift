//
//  ViewController.swift
//  DUTInfomation
//
//  Created by shino on 2017/7/3.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit

class CostViewController: TabViewController {
    @IBOutlet weak var netCostLabel: UILabel!
    @IBOutlet weak var netFlowLabel: UILabel!
    @IBOutlet weak var ecardCostLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dutInfo.loginNewPortalSite(succeed: {
            self.dutInfo.newPortalNetInfo()
        }, failed: {
            self.performSegue(withIdentifier: "LoginTeach", sender: self)
        })
    }
    
    override func setEcardCost(_ ecardCost: String) {
        DispatchQueue.main.async {
            self.ecardCostLabel.text = ecardCost
        }
    }
    
    override func setNetCost(_ netCost: String) {
        DispatchQueue.main.async {
            self.netCostLabel.text = netCost
        }
    }
    
    override func setNetFlow(_ netFlow: String) {
        DispatchQueue.main.async {
            self.netFlowLabel.text = netFlow
        }
    }
}
