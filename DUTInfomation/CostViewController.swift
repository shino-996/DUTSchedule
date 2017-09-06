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
    
    lazy var dutInfo = DUTInfo.share

    override func viewDidLoad() {
        super.viewDidLoad()
        dutInfo.delegate = self
//        dutInfo.fetchData()
        dutInfo.scheduleInfo()
    }
    
    @IBAction func testButton() {
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")
        let fileURL = groupURL!.appendingPathComponent("course.plist")
        let courseData = NSArray(contentsOf: fileURL)!
        print(courseData)
    }
    
    func setEcardCost() {
        DispatchQueue.main.async {
            self.ecardCostLabel.text = self.dutInfo.ecardCost
        }
    }
    
    func setNetCost() {
        DispatchQueue.main.async {
            self.netCostLabel.text = self.dutInfo.netCost
            let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
            userDefaults.set(false, forKey: "IsNetError")
        }
    }
    
    func setNetFlow() {
        DispatchQueue.main.async {
            self.netFlowLabel.text = self.dutInfo.netFlow
            let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
            userDefaults.set(false, forKey: "IsNetError")
        }
    }
    
    func netErrorHandle() {
        UserDefaults(suiteName: "group.dutinfo.shino.space")?.set(true, forKey: "IsNetError")
    }
}
