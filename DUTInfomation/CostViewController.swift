//
//  ViewController.swift
//  DUTInfomation
//
//  Created by shino on 2017/7/3.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit
import DUTInfo

class CostViewController: TabViewController {
    @IBOutlet weak var netCostLabel: UILabel!
    @IBOutlet weak var netCostActivity: UIActivityIndicatorView!
    @IBOutlet weak var netFlowLabel: UILabel!
    @IBOutlet weak var netFlowActivity: UIActivityIndicatorView!
    @IBOutlet weak var ecardCostLabel: UILabel!
    @IBOutlet weak var ecardActivity: UIActivityIndicatorView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var studentButton: UIButton!
    
    var testInfo: TestInfo!
    var cacheInfo: CacheInfo!
    var dataSource: TestViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testInfo = TestInfo()
        cacheInfo = CacheInfo()
        dataSource = TestViewDataSource(tests: testInfo.tests)
        tableview.dataSource = dataSource
        loadCache()
    }
    
    func loadCache() {
        let (cost, flow) = cacheInfo.netInfo
        netCostLabel.text = cost
        netFlowLabel.text = flow
        ecardCostLabel.text = cacheInfo.ecard
        nameButton.setTitle(cacheInfo.name, for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if cacheInfo.shouldRefresh() {
            netCostActivity.startAnimating()
            netFlowActivity.startAnimating()
            ecardActivity.startAnimating()
            cacheInfo.loadCacheAsync() {
                DispatchQueue.main.async {
                    self.netCostActivity.stopAnimating()
                    self.netFlowActivity.stopAnimating()
                    self.ecardActivity.stopAnimating()
                    self.loadCache()
                }
            }
        }
        if testInfo.tests == nil {
            testInfo.loadTestAsync() {
                self.dataSource.tests = self.testInfo.tests
                DispatchQueue.main.async {
                    self.dataSource.tests = self.testInfo.tests
                    self.tableview.reloadData()
                }
            }
        }
    }
    
    @IBAction func changeAccount() {
        let alertController = UIAlertController(title: "登录账号", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "注销", style: .default) { _ in
            KeyInfo.shared.removeAccount()
            CourseManager().deleteAllCourse()
            TestInfo.deleteTest()
            CacheInfo.deleteCache()
            (self.tabBarController as! TabBarController).isLogin = false
            self.isLogin = false
        }
        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
