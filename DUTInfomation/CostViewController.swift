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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if dutInfo == nil {
            dutInfo = DUTInfo(())
        }
        guard dutInfo != nil else {
            performSegue(withIdentifier: "LoginTeach", sender: self)
            return
        }
        dutInfo.delegate = self
        dutInfo.ecardInfo()
        dutInfo.netInfo()
    }
    
    func setEcardCost() {
        DispatchQueue.main.async {
            self.ecardCostLabel.text = self.dutInfo.ecardCost
        }
    }
    
    func setNetCost() {
        DispatchQueue.main.async {
            self.netCostLabel.text = self.dutInfo.netCost
        }
    }
    
    func setNetFlow() {
        DispatchQueue.main.async {
            self.netFlowLabel.text = self.dutInfo.netFlow
        }
    }
    
    func netErrorHandle() {
    }
}
