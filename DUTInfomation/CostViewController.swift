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
    @IBOutlet weak var tableview: UITableView!
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dutInfo.loginNewPortalSite(succeed: { [unowned self] in
            self.dutInfo.newPortalNetInfo()
        }, failed: { [unowned self] in
            self.performSegue(withIdentifier: "LoginTeach", sender: self)
        })
        if testInfo.allTests == nil {
            dutInfo.loginTeachSite(succeed: { [unowned self] in
                self.dutInfo.testInfo()
            }, failed: { [unowned self] in
                self.performSegue(withIdentifier: "LoginTeach", sender: self)
            })
        }
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
    
    override func setTest(_ testArray: [[String : String]]) {
        testInfo.allTests = testArray
    }
}
