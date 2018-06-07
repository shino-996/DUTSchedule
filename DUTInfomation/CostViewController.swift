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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = TestViewDataSource(tests: dataManager.tests())
        tableview.dataSource = dataSource
        
        loadData()
        addObserver()
    }
    
    func loadData() {
        netCostActivity.startAnimating()
        netFlowActivity.startAnimating()
        ecardActivity.startAnimating()
        DispatchQueue.global().async {
            self.dataManager.load([.net, .ecard, .test])
        }
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "space.shino.post.net"),
                                               object: nil,
                                               queue: nil) { _ in
            let netData = self.dataManager.net()
            DispatchQueue.main.async {
                self.netCostLabel.text = "\(netData.cost)"
                self.netFlowLabel.text = "\(netData.flow)"
                self.netCostActivity.stopAnimating()
                self.netFlowActivity.stopAnimating()
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "space.shino.post.ecard"),
                                               object: nil,
                                               queue: nil) { _ in
            let ecardData = self.dataManager.ecard()
            DispatchQueue.main.async {
                self.ecardCostLabel.text = "\(ecardData.ecard)"
                self.ecardActivity.stopAnimating()
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "space.shino.post.test"),
                                               object: nil,
                                               queue: nil) { _ in
            let testData = self.dataManager.tests()
            self.dataSource.tests = testData
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
    }
    
    @IBAction func changeAccount() {
        let alertController = UIAlertController(title: "登录账号", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "注销", style: .default) { _ in
            UserInfo.shared.removeAccount()
//            DataManager().deleteAllCourse()
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "space.shino.post.login")))
        }
        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
