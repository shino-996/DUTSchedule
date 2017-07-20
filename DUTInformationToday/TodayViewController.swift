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
    @IBOutlet weak var errorButton: UIButton!
    
    var dutInfo: DUTInfo!
    var freshingNum: Int! {
        didSet {
            if freshingNum == 0 {
                activityIndicator.stopAnimating()
                let now = Date().timeIntervalSince1970
                let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
                userDefaults.set(now, forKey: "LastUpdateDate")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadData() {
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        errorButton.isHidden = !userDefaults.bool(forKey: "IsNetError")
        ecardCostLabel.text = userDefaults.string(forKey: "EcardCost")!
        netCostLabel.text = userDefaults.string(forKey: "NetCost")!
        netFlowLabel.text = userDefaults.string(forKey: "NetFlow")!
    }
    
    func freshData() {
        dutInfo = DUTInfo()
        dutInfo.studentNumber = "201487033"
        dutInfo.teachPassword = "220317"
        dutInfo.portalPassword = "shino$sshLoca1"
        dutInfo.delegate = self
        activityIndicator.startAnimating()
        freshingNum = 3
        dutInfo.ecardInfo()
        dutInfo.netInfo()
        errorButton.isHidden = false
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        var result = NCUpdateResult.failed
        loadData()
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        let lastUpdateDate = userDefaults.double(forKey: "LastUpdateDate")
        let now = Date().timeIntervalSince1970
        if now - lastUpdateDate < 1800 {
            result = .noData
        } else {
            freshData()
        }
        completionHandler(result)
    }
    
    @IBAction func forceFreshData() {
        freshData()
    }
}

extension TodayViewController: DUTInfoDelegate {
    func setEcardCost() {
        DispatchQueue.main.async {
            self.ecardCostLabel.text = self.dutInfo.ecardCost
            let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
            userDefaults.set(self.dutInfo.ecardCost, forKey: "EcardCost")
        }
        freshingNum = freshingNum - 1
    }
    
    func setNetCost() {
        DispatchQueue.main.async {
            self.netCostLabel.text = self.dutInfo.netCost
            let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
            userDefaults.set(self.dutInfo.netCost, forKey: "NetCost")
            userDefaults.set(false, forKey: "IsNetError")
        }
        freshingNum = freshingNum - 1
    }
    
    func setNetFlow() {
        DispatchQueue.main.async {
            self.netFlowLabel.text = self.dutInfo.netFlow
            let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
            userDefaults.set(self.dutInfo.netFlow, forKey: "NetFlow")
            userDefaults.set(false, forKey: "IsNetError")
        }
        freshingNum = freshingNum - 1
    }
    
    func netErrorHandle() {
        UserDefaults(suiteName: "group.dutinfo.shino.space")?.set(true, forKey: "IsNetError")
        freshingNum = freshingNum - 2
    }
}
