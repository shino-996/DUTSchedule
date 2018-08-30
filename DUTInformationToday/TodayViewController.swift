//
//  TodayViewController.swift
//  DUTInformationToday
//
//  Created by shino on 2017/7/9.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var netLabel: UILabel!
    @IBOutlet weak var ecardLabel: UILabel!
    @IBOutlet weak var netActivity: UIActivityIndicatorView!
    @IBOutlet weak var ecardActivity: UIActivityIndicatorView!
    @IBOutlet weak var noCourseButton: UIButton!
    @IBOutlet weak var courseTableView: UITableView!
    @IBOutlet weak var weekButton: UIButton!
    
    let dataManager = DataManager()
    var dataSource: TodayViewDataSource!
    var isLogin: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        let date = Date()
        dataSource = TodayViewDataSource(courses: dataManager.courses(of: .today(date)), date: date)
        dataSource.controller = self
        courseTableView.dataSource = dataSource
        if UserInfo.shared.isLogin {
            isLogin = true
            noCourseButton.isEnabled = false
            addObserver()
            freshSchedule()
        } else {
            isLogin = false
            noCourseButton.isEnabled = true
            noCourseButton.setTitle("未登录账号", for: .normal)
        }
    }
    
    func addObserver() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(freshNetCostUI),
                                       name: Notification.Name(rawValue: "space.shino.post.finishfetch"),
                                       object: nil)
    }
    
    func load() {
        ecardActivity.startAnimating()
        netActivity.startAnimating()
        DispatchQueue.global().async {
            self.dataManager.load([.net, .ecard])
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        if isLogin {
            load()
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
    }
    
    @IBAction func changeSchedule(_ sender: UIButton) {
        let title = sender.title(for: .normal)
        if title == "⇨" {
            let date = dataSource.date
            dataSource.courses = dataManager.courses(of: .nextDay(date))
            dataSource.date = date.nextDate()
        } else if title == "⇦" {
            let date = dataSource.date
            dataSource.courses = dataManager.courses(of: .lastDay(date))
            dataSource.date = date.lastDate()
        } else {
            let date = Date()
            dataSource.courses = dataManager.courses(of: .today(date))
            dataSource.date = date
        }
        freshSchedule()
    }
    
    @IBAction func awakeHost(_ sender: UIButton) {
        extensionContext?.open(URL(string: "dutinformation://")!, completionHandler: nil)
    }
}

// 更新UI相关
extension TodayViewController {
    @objc func freshNetCostUI() {
        DispatchQueue.main.async {
            self.setNetCost()
            self.ecardActivity.stopAnimating()
            self.netActivity.stopAnimating()
        }
    }
    
    func setNetCost() {
        if let net = dataManager.net(),
            let ecard = dataManager.ecard() {
            netLabel.text = net.flowStr() + "/" + net.costStr()
            ecardLabel.text = ecard.ecardStr()
        }
    }
    
    func freshSchedule() {
        courseTableView.reloadData()
        weekButton.setTitle("第\(dataSource.date.teachweek())周 周\(dataSource.date.weekDayStr())",
                            for: .normal)
        if dataSource.courses.count == 0 {
            noCourseButton.isHidden = false
            noCourseButton.setTitle("今天没有课～", for: .normal)
        } else {
            noCourseButton.isHidden = true
            if dataSource.courses.count > 1 {
                extensionContext?.widgetLargestAvailableDisplayMode = .expanded
            } else {
                extensionContext?.widgetLargestAvailableDisplayMode = .compact
            }
        }
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            preferredContentSize = maxSize
        }
        if activeDisplayMode == .expanded {
            preferredContentSize = CGSize(width: 0,
                                          height: 110 + 61.5 * Double(dataSource.courses.count - 1))
        }
        if dataSource.courses.count > 0 {
            let index = IndexPath(item: 0, section: 0)
            courseTableView.reloadRows(at: [index], with: .automatic)
        }
    }
}
