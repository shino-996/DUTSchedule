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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var dutInfo: DUTInfo!
    var freshingNum: Int! {
        didSet {
            if freshingNum == 0 {
                activityIndicator.stopAnimating()
                let now = Date().timeIntervalSince1970
                UserDefaults.standard.set(now, forKey: "LastUpdateDate")
                print("\(now), set up")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let lastUpdateDate = UserDefaults.standard.double(forKey: "LastUpdateDate")
        let now = Date().timeIntervalSince1970
        if now - lastUpdateDate < 1800 {
            ecardCostLabel.text = UserDefaults.standard.string(forKey: "EcardCost")!
            netCostLabel.text = UserDefaults.standard.string(forKey: "NetCost")!
            netFlowLabel.text = UserDefaults.standard.string(forKey: "NetFlow")!
            print(now)
            return
        }
        dutInfo = DUTInfo()
        dutInfo.studentNumber = "201487033"
        dutInfo.teachPassword = "220317"
        dutInfo.portalPassword = "shino$sshLoca1"
        freshInfo()
    }
    
    func freshInfo() {
        activityIndicator.startAnimating()
        freshingNum = 2
        dutInfo.ecardInfo() {
            DispatchQueue.main.async {
                self.ecardCostLabel.text = self.dutInfo.ecardCost
                UserDefaults.standard.set(self.dutInfo.ecardCost, forKey: "EcardCost")
                self.freshingNum = self.freshingNum - 1
            }
        }
        dutInfo.netInfo {
            DispatchQueue.main.async {
                self.netCostLabel.text = self.dutInfo.netCost
                self.netFlowLabel.text = self.dutInfo.netFlow
                UserDefaults.standard.set(self.dutInfo.netCost, forKey: "NetCost")
                UserDefaults.standard.set(self.dutInfo.netFlow, forKey: "NetFlow")
                self.freshingNum = self.freshingNum - 1
            }
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        print("1")
        completionHandler(NCUpdateResult.newData)
    }
    
}
