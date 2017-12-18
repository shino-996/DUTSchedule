//
//  TodayViewController.swift
//  DUTInformationToday
//
//  Created by shino on 2017/7/9.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit
import NotificationCenter

//变量
class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var netLabel: UILabel!
    @IBOutlet weak var ecardLabel: UILabel!
    @IBOutlet weak var netActivity: UIActivityIndicatorView!
    @IBOutlet weak var ecardActivity: UIActivityIndicatorView!
    @IBOutlet weak var noCourseButton: UIButton!
    @IBOutlet weak var courseTableView: UITableView!
    @IBOutlet weak var weekLabel: UILabel!
    
    var dutInfo: DUTInfo!
    var courseInfo: CourseInfo!
    var dataSource: TodayViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOSApplicationExtension 10.0, *) {
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        let studentNumber = userDefaults.string(forKey: "StudentNumber") ?? ""
        let teachPassword = userDefaults.string(forKey: "TeachPassword") ?? ""
        let portalPassword = userDefaults.string(forKey: "PortalPassword") ?? ""
        dutInfo = DUTInfo(studentNumber: studentNumber,
                          teachPassword: teachPassword,
                          portalPassword: portalPassword)
        dutInfo.delegate = self
        courseInfo = CourseInfo()
        dataSource = TodayViewDataSource()
        courseTableView.dataSource = dataSource
        dataSource.controller = self
        dataSource.freshUIHandler = freshUI
        dataSource.data = courseInfo.coursesToday(dataSource.data.date)
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        loadCacheData()
        dutInfo.loginNewPortalSite(succeed: {
            self.dutInfo.newPortalNetInfo()
            DispatchQueue.main.async {
                self.ecardActivity.startAnimating()
                self.netActivity.startAnimating()
            }
        }, failed: {
            DispatchQueue.main.async {
                self.noCourseButton.setTitle("未登录账号", for: .normal)
            }
        })
        completionHandler(.newData)
    }
    
    @IBAction func changeSchedule(_ sender: Any) {
        if sender is UITapGestureRecognizer {
            dataSource.data = courseInfo.coursesToday(Date())
        } else {
            let button = sender as! UIButton
            if button.title(for: .normal) == "->" {
                dataSource.data = courseInfo.coursesNextDay(dataSource.data.date)
            } else {
                dataSource.data = courseInfo.coursesLastDay(dataSource.data.date)
            }
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
    func loadCacheData() {
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        ecardLabel.text = userDefaults.string(forKey: "EcardCost") ?? ""
        if let netCost = userDefaults.string(forKey: "NetCost"),
            let netFlow = userDefaults.string(forKey: "NetFlow") {
            netLabel.text = netFlow + "/" + netCost
        } else {
            netLabel.text = ""
        }
    }
    
    func freshUI() {
        courseTableView.reloadData()
        let chineseWeek = ["日", "一", "二", "三", "四", "五", "六"]
        weekLabel.text = "第\(self.dataSource.data.weeknumber)周 周\(chineseWeek[self.dataSource.data.week])"
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
        DispatchQueue.main.async {
            self.ecardLabel.text = ecardCost
            self.ecardActivity.stopAnimating()
        }
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        userDefaults.set(ecardCost, forKey: "EcardCost")
    }
    
    func setNetFlow(_ netFlow: String) {
        DispatchQueue.main.async {
            self.netLabel.text = netFlow + "/" + self.dutInfo.netCost
            self.netActivity.stopAnimating()
        }
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        userDefaults.set(dutInfo.netCost, forKey: "NetCost")
        userDefaults.set(netFlow, forKey: "NetFlow")
    }
    
    func setNetCost(_ netCost: String) {}
    func netErrorHandle(_ error: Error) {}
    func setSchedule(_ courseArray: [[String : String]]) {}
    func setTest(_ testArray: [[String : String]]) {}
}
