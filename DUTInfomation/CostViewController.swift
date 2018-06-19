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
    @IBOutlet weak var studentButton: UIButton!
    
    var dataSource: TestViewDataSource!
    private var lastFreshTime: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = TestViewDataSource(tests: dataManager.tests())
        tableview.dataSource = dataSource
        setNetCost()
        addObserver()
        DispatchQueue.global().async {
            self.dataManager.load([.test])
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let lastTime = lastFreshTime ?? .distantPast
        if Date().timeIntervalSince(lastTime) > 60 {
            loadData()
        }
    }
    
    func loadData() {
        netCostActivity.startAnimating()
        netFlowActivity.startAnimating()
        ecardActivity.startAnimating()
        DispatchQueue.global().async {
            self.dataManager.load([.net, .ecard])
        }
    }
    
    func addObserver() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(freshNetCostUI),
                                       name: Notification.Name(rawValue: "space.shino.post.finishfetch"),
                                       object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(freshTestUI),
                                       name: Notification.Name(rawValue: "space.shino.post.test"),
                                       object: nil)
    }
    
    @IBAction func changeAccount() {
        let alertController = UIAlertController(title: "登录账号", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "注销", style: .default) { _ in
            self.dataManager.deleteAll()
            self.performSegue(withIdentifier: "Login", sender: self)
        }
        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

// 更新UI
extension CostViewController {
    @objc func freshNetCostUI() {
        DispatchQueue.main.async {
            self.setNetCost()
            self.netCostActivity.stopAnimating()
            self.netFlowActivity.stopAnimating()
            self.ecardActivity.stopAnimating()
            self.lastFreshTime = Date()
        }
    }
    
    func setNetCost() {
        if let netData = self.dataManager.net(),
            let ecardData = self.dataManager.ecard() {
            netCostLabel.text = "\(netData.cost)"
            netFlowLabel.text = "\(netData.flow)"
            ecardCostLabel.text = "\(ecardData.ecard)"
        }
    }
    
    @objc func freshTestUI() {
        DispatchQueue.main.async {
            let testData = self.dataManager.tests()
            self.dataSource.tests = testData
            self.tableview.reloadData()
        }
    }
}
