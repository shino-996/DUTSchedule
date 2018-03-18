//
//  TodayViewController.swift
//  DUTInformationToday
//
//  Created by shino on 2017/7/9.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit
import NotificationCenter
import DUTInfo

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var netLabel: UILabel!
    @IBOutlet weak var ecardLabel: UILabel!
    @IBOutlet weak var netActivity: UIActivityIndicatorView!
    @IBOutlet weak var ecardActivity: UIActivityIndicatorView!
    @IBOutlet weak var noCourseButton: UIButton!
    @IBOutlet weak var courseTableView: UITableView!
    @IBOutlet weak var weekButton: UIButton!
    
    var courseInfo: CourseInfo!
    var cacheInfo: CacheInfo!
    var dataSource: TodayViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        courseInfo = CourseInfo()
        cacheInfo = CacheInfo()
        dataSource = TodayViewDataSource(data: courseInfo.coursesToday())
        dataSource.controller = self
        courseTableView.dataSource = dataSource
    }
    
    func loadInfo() {
        ecardActivity.stopAnimating()
        netActivity.stopAnimating()
        let (cost, flow) = cacheInfo.netInfo
        netLabel.text = flow + "/" + cost
        ecardLabel.text = cacheInfo.ecard
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        if cacheInfo.shouldRefresh() {
            ecardActivity.startAnimating()
            netActivity.startAnimating()
            cacheInfo.loadCacheAsync() {
                DispatchQueue.main.async {
                    self.loadInfo()
                }
            }
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
            if dataSource.data.courses!.count > 1 {
                extensionContext?.widgetLargestAvailableDisplayMode = .expanded
            } else {
                extensionContext?.widgetLargestAvailableDisplayMode = .compact
            }
        } else {
            noCourseButton.isHidden = false
            noCourseButton.setTitle("未导入课程表", for: .normal)
        }
    }
    
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
