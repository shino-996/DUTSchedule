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
        
        notificationCenter.addObserver(forName: Notification.Name(rawValue: "space.shino.post.net"),
                                               object: nil,
                                               queue: nil) { _ in
            let netData = self.dataManager.net()
            DispatchQueue.main.async {
                self.netLabel.text = "\(netData.flow)/\(netData.cost)"
                self.netActivity.stopAnimating()
            }
        }
        
        notificationCenter.addObserver(forName: Notification.Name(rawValue: "space.shino.post.ecard"),
                                               object: nil,
                                               queue: nil) { _ in
            let ecardData = self.dataManager.ecard()
            DispatchQueue.main.async {
                self.ecardLabel.text = "\(ecardData.ecard)"
                self.ecardActivity.stopAnimating()
            }
        }
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
    func freshSchedule() {
        courseTableView.reloadData()
        let chineseWeek = ["日", "一", "二", "三", "四", "五", "六"]
        weekButton.setTitle("第\(self.dataSource.date.teachweek())周 周\(chineseWeek[self.dataSource.date.weekday()])", for: UIControl.State.normal)
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
