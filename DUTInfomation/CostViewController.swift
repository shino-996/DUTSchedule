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
    @IBOutlet weak var netCostActivity: UIActivityIndicatorView!
    @IBOutlet weak var netFlowLabel: UILabel!
    @IBOutlet weak var netFlowActivity: UIActivityIndicatorView!
    @IBOutlet weak var ecardCostLabel: UILabel!
    @IBOutlet weak var ecardActivity: UIActivityIndicatorView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var studentLabel: UILabel!
    
    var testInfo: TestInfo!
    var dataSource: TestViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testInfo = TestInfo()
        dataSource = TestViewDataSource()
        dataSource.freshUIHandler = { [unowned self] in
            self.tableview.reloadData()
        }
        dataSource.tests = testInfo.allTests
        tableview.dataSource = dataSource
        loadCache()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dutInfo.loginNewPortalSite(succeed: { [weak self] in
            self?.dutInfo.newPortalNetInfo()
            self?.dutInfo.newPortalPersonInfo()
            self?.netCostActivity.startAnimating()
            self?.netFlowActivity.startAnimating()
            self?.ecardActivity.startAnimating()
        }, failed: { [weak self] in
            self?.performSegue(withIdentifier: "LoginTeach", sender: self)
        })
        if testInfo.allTests == nil {
            dutInfo.loginTeachSite(succeed: { [weak self] in
                self?.dutInfo.testInfo()
            }, failed: { [weak self] in
                self?.performSegue(withIdentifier: "LoginTeach", sender: self)
            })
        }
    }
    
    func loadCache() {
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        ecardCostLabel.text = userDefaults.string(forKey: "EcardCost") ?? ""
        nameLabel.text = userDefaults.string(forKey: "PersonName") ?? ""
        studentLabel.text = dutInfo.studentNumber
        netCostLabel.text = userDefaults.string(forKey: "NetCost") ?? ""
        netFlowLabel.text = userDefaults.string(forKey: "NetFlow") ?? ""
    }
    
    override func setEcardCost(_ ecardCost: String) {
        DispatchQueue.main.async { [weak self] in
            self?.ecardCostLabel.text = ecardCost
            self?.ecardActivity.stopAnimating()
        }
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        userDefaults.set(ecardCost, forKey: "ECardCost")
    }
    
    override func setNetFlow(_ netFlow: String) {
        DispatchQueue.main.async { [weak self] in
            self?.netFlowLabel.text = netFlow
            self?.netCostLabel.text = self?.dutInfo.netCost
            self?.netFlowActivity.stopAnimating()
            self?.netCostActivity.stopAnimating()
        }
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        userDefaults.set(dutInfo.netCost, forKey: "NetCost")
        userDefaults.set(netFlow, forKey: "NetFlow")
    }
    
    override func setPersonName(_ personName: String) {
        if nameLabel.text ?? "" != "" {
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.nameLabel.text = personName
        }
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        userDefaults.set(personName, forKey: "PersonName")
    }
    
    override func setTest(_ testArray: [[String : String]]) {
        testInfo.allTests = testArray
    }
}
