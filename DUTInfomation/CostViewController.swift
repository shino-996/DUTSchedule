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
        infoInit()
        dataSource = TestViewDataSource()
        dataSource.freshUIHandler = { [weak self] in
            self?.tableview.reloadData()
        }
        dataSource.tests = testInfo.allTests
        tableview.dataSource = dataSource
    }
    
    func infoInit() {
        testInfo = TestInfo()
        cacheInfo = CacheInfo()
        cacheInfo.netCostHandle = { [weak self] cost in
            DispatchQueue.main.async {
                self?.netCostLabel.text = cost
                self?.netCostActivity.stopAnimating()
            }
        }
        cacheInfo.netFlowHandle = { [weak self] flow in
            DispatchQueue.main.async {
                self?.netFlowLabel.text = flow
                self?.netFlowActivity.stopAnimating()
            }
        }
        cacheInfo.ecardCostHandle = { [weak self] ecard in
            DispatchQueue.main.async {
                self?.ecardCostLabel.text = ecard
                self?.ecardActivity.stopAnimating()
            }
        }
        cacheInfo.personNameHandle = { [weak self] name in
            DispatchQueue.main.async {
                self?.nameButton.setTitle(name, for: .normal)
                self?.studentButton.setTitle(self?.dutInfo.studentNumber, for: .normal)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if cacheInfo.shouldRefresh() {
            netCostActivity.startAnimating()
            netFlowActivity.startAnimating()
            ecardActivity.startAnimating()
            DispatchQueue.global().async { [weak self] in
                if self?.dutInfo.loginPortal() ?? false {
                    let (cost, flow) = self!.dutInfo.netInfo()
                    self?.cacheInfo.netCost = cost
                    self?.cacheInfo.netFlow = flow
                    let ecard = self!.dutInfo.moneyInfo()
                    self?.cacheInfo.ecardCost = ecard
                    let name = self!.dutInfo.personInfo()
                    self?.cacheInfo.personName = name
                } else {
                    DispatchQueue.main.async {
                        self?.netCostActivity.stopAnimating()
                        self?.netFlowActivity.stopAnimating()
                        self?.ecardActivity.stopAnimating()
                    }
                    self?.performLogin()
                }
            }
        }
        if testInfo.allTests == nil {
            DispatchQueue.global().async { [weak self] in
                if self?.dutInfo.loginTeachSite() ?? false {
                    self?.testInfo.allTests = self?.dutInfo.testInfo()
                    self?.dataSource.tests = self?.testInfo.allTests
                } else {
                    self?.performLogin()
                }
            }
        }
    }
    
    @IBAction func changeAccount() {
        let alertController = UIAlertController(title: "登录账号", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "注销", style: .default) { [weak self] _ in
            let account = KeyInfo.getCurrentAccount()!["number"]!
            KeyInfo.removePasword(ofStudentnumber: account)
            var accounts = KeyInfo.getAccounts()!
            accounts.removeLast()
            KeyInfo.updateAccounts(accounts: accounts)
            self?.dutInfo = DUTInfo(studentNumber: "", teachPassword: "", portalPassword: "")
            self?.performLogin()
            CourseInfo.deleteCourse()
            TestInfo.deleteTest()
            CacheInfo.deleteCache()
            self?.infoInit()
        }
        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
