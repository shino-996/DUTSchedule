//
//  TodayViewController.swift
//  DUTInformationToday
//
//  Created by shino on 2017/7/9.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var netLabel: UILabel!
    @IBOutlet weak var ecardLabel: UILabel!
    @IBOutlet weak var netActivity: UIActivityIndicatorView!
    @IBOutlet weak var ecardActivity: UIActivityIndicatorView!
    @IBOutlet weak var noCourseButton: UIButton!
    @IBOutlet weak var courseTableView: UITableView!
    @IBOutlet weak var weekButton: UIButton!
    
    var dutInfo: DUTInfo!
    var courseInfo: CourseInfo!
    var cacheInfo: CacheInfo!
    var dataSource: TodayViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOSApplicationExtension 10.0, *) {
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        dutInfo = DUTInfo()
        if let studentNumber = KeyInfo.getCurrentAccount() {
            let (teachPassword, portalPassword) = KeyInfo.loadPassword(studentNumber: studentNumber)
            dutInfo.studentNumber = studentNumber
            dutInfo.teachPassword = teachPassword
            dutInfo.portalPassword = portalPassword
        }
        dutInfo.delegate = self
        courseInfo = CourseInfo()
        cacheInfo = CacheInfo()
        cacheInfo.netCostHandle = { [weak self] in
            DispatchQueue.main.async {
                self?.netLabel.text = (self?.cacheInfo.netFlow ?? "") + "/" + (self?.cacheInfo.netCost ?? "")
                self?.netActivity.stopAnimating()
            }
        }
        cacheInfo.netFlowHandle = { [weak self] in
            DispatchQueue.main.async {
                self?.netLabel.text = (self?.cacheInfo.netFlow ?? "") + "/" + (self?.cacheInfo.netCost ?? "")
                self?.netActivity.stopAnimating()
            }
        }
        cacheInfo.ecardCostHandle = { [weak self] in
            DispatchQueue.main.async {
                self?.ecardLabel.text = self?.cacheInfo.ecardCost
                self?.ecardActivity.stopAnimating()
            }
        }
        dataSource = TodayViewDataSource()
        courseTableView.dataSource = dataSource
        dataSource.controller = self
        dataSource.freshUIHandler = freshUI
        dataSource.data = courseInfo.coursesToday(Date())
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        if cacheInfo.shouldRefresh() {
            ecardActivity.startAnimating()
            netActivity.startAnimating()
            dutInfo.loginNewPortalSite(succeed: { [weak self] in
                self?.dutInfo.newPortalNetInfo()
            }, failed: { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    self?.ecardActivity.stopAnimating()
                    self?.netActivity.stopAnimating()
                    self?.noCourseButton.setTitle("未登录账号", for: .normal)
                }
            })
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
    }
    
    @IBAction func changeSchedule(_ sender: UIButton) {
        let title = sender.title(for: .normal)
        if title == "⇨" {
            dataSource.data = courseInfo.coursesNextDay(dataSource.data.date)
        } else if title == "⇦" {
            dataSource.data = courseInfo.coursesLastDay(dataSource.data.date)
        } else {
            dataSource.data = courseInfo.coursesToday(Date())
        }
    }
    
    @IBAction func awakeHost(_ sender: UIButton) {
        if sender.title(for: .normal) == "未导入课程表" {
            extensionContext?.open(URL(string: "dutinformation://")!, completionHandler: nil)
        } else if sender.title(for: .normal) == "未登录账号" {
            extensionContext?.open(URL(string: "dutinformation://")!, completionHandler: nil)
        }
    }
}

// 更新UI相关
extension TodayViewController {
    func freshUI() {
        courseTableView.reloadData()
        let chineseWeek = ["日", "一", "二", "三", "四", "五", "六"]
        weekButton.setTitle("第\(self.dataSource.data.weeknumber)周 周\(chineseWeek[self.dataSource.data.week])", for: .normal)
        if dataSource.data.courses != nil {
            if dataSource.data.courses!.count == 0 {
                noCourseButton.isHidden = false
                noCourseButton.setTitle("今天没有课～", for: .normal)
            } else {
                noCourseButton.isHidden = true
            }
            if #available(iOSApplicationExtension 10.0, *) {
                if dataSource.data.courses!.count > 1 {
                    extensionContext?.widgetLargestAvailableDisplayMode = .expanded
                } else {
                    extensionContext?.widgetLargestAvailableDisplayMode = .compact
                }
            }
        } else {
            noCourseButton.isHidden = false
            noCourseButton.setTitle("未导入课程表", for: .normal)
        }
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            preferredContentSize = maxSize
        }
        guard dataSource.data.courses != nil else {
            preferredContentSize = CGSize(width: 0, height: 110)
            return
        }
        if activeDisplayMode == .expanded {
            preferredContentSize = CGSize(width: 0,
                                          height: 110 + 61.5 * Double(dataSource.data.courses!.count - 1))
        }
        if dataSource.data.courses!.count > 0 {
            let index = IndexPath(item: 0, section: 0)
            courseTableView.reloadRows(at: [index], with: .automatic)
        }
    }
}

extension TodayViewController: DUTInfoDelegate {
    func setEcardCost(_ ecardCost: String) {
        cacheInfo.ecardCost = ecardCost
    }
    
    func setNetCost(_ netCost: String) {
        cacheInfo.netCost = netCost
    }
    
    func setNetFlow(_ netFlow: String) {
        cacheInfo.netFlow = netFlow
    }
    
    func netErrorHandle(_ error: Error) {}
    func setSchedule(_ courseArray: [[String : String]]) {}
    func setTest(_ testArray: [[String : String]]) {}
    func setPersonName(_ personName: String) {}
}
