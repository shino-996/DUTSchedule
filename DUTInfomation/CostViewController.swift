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
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var studentLabel: UILabel!
    
    var testInfo: TestInfo!
    var cacheInfo: CacheInfo!
    var dataSource: TestViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testInfo = TestInfo()
        cacheInfo = CacheInfo()
        cacheInfo.netCostHandle = { [weak self] in
            DispatchQueue.main.async {
                self?.netCostLabel.text = self?.cacheInfo.netCost
                self?.netCostActivity.stopAnimating()
            }
        }
        cacheInfo.netFlowHandle = { [weak self] in
            DispatchQueue.main.async {
                self?.netFlowLabel.text = self?.cacheInfo.netFlow
                self?.netFlowActivity.stopAnimating()
            }
        }
        cacheInfo.ecardCostHandle = { [weak self] in
            DispatchQueue.main.async {
                self?.ecardCostLabel.text = self?.cacheInfo.ecardCost
                self?.ecardActivity.stopAnimating()
            }
        }
        cacheInfo.personNameHandle = { [weak self] in
            DispatchQueue.main.async {
                self?.nameButton.setTitle(self?.cacheInfo.personName, for: .normal)
                self?.studentLabel.text = self?.dutInfo.studentNumber
            }
        }
        dataSource = TestViewDataSource()
        dataSource.freshUIHandler = { [weak self] in
            self?.tableview.reloadData()
        }
        dataSource.tests = testInfo.allTests
        tableview.dataSource = dataSource
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if cacheInfo.shouldRefresh() {
            netCostActivity.startAnimating()
            netFlowActivity.startAnimating()
            ecardActivity.startAnimating()
            dutInfo.loginNewPortalSite(succeed: { [weak self] in
                self?.dutInfo.newPortalNetInfo()
                self?.dutInfo.newPortalPersonInfo()
            }, failed: { [weak self] in
                self?.netCostActivity.stopAnimating()
                self?.netFlowActivity.stopAnimating()
                self?.ecardActivity.stopAnimating()
                self?.performLogin()
            })
        }
        if testInfo.allTests == nil {
            dutInfo.loginTeachSite(succeed: { [weak self] in
                self?.dutInfo.testInfo()
            }, failed: { [weak self] in
                self?.performLogin()
            })
        }
    }
    
    @IBAction func changeAccount() {
        let alertController = UIAlertController(title: "登录账号", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "注销", style: .default) { [weak self] _ in
            let account = KeyInfo.getCurrentAccount()!
            KeyInfo.removePasword(ofStudentnumber: account)
            var accounts = KeyInfo.getAccounts()!
            accounts.removeLast()
            KeyInfo.updateAccounts(accounts: accounts)
            self?.dutInfo.studentNumber = ""
            self?.dutInfo.teachPassword = ""
            self?.dutInfo.portalPassword = ""
            self?.performLogin()
            CourseInfo.deleteCourse()
            TestInfo.deleteTest()
            CacheInfo.deleteCache()
        }
        let changeAccountAction = UIAlertAction(title: "切换账号", style: .default) { _ in
        }
        alertController.addAction(logoutAction)
        alertController.addAction(changeAccountAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func setEcardCost(_ ecardCost: String) {
        cacheInfo.ecardCost = ecardCost
    }
    
    override func setNetCost(_ netCost: String) {
        cacheInfo.netCost = netCost
    }
    
    override func setNetFlow(_ netFlow: String) {
        cacheInfo.netFlow = netFlow
    }
    
    override func setPersonName(_ personName: String) {
        cacheInfo.personName = personName
    }
    
    override func setTest(_ testArray: [[String : String]]) {
        testInfo.allTests = testArray
        dataSource.tests = testInfo.allTests
    }
}
