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
class TodayViewController: UIViewController {
    @IBOutlet weak var netLabel: UILabel!
    @IBOutlet weak var ecardLabel: UILabel!
    @IBOutlet weak var netActivity: UIActivityIndicatorView!
    @IBOutlet weak var ecardActivity: UIActivityIndicatorView!
    @IBOutlet weak var noCourseButton: UIButton!
    @IBOutlet weak var courseTableView: UITableView!
    @IBOutlet weak var weekLabel: UILabel!
    
    var dutInfo: DUTInfo!
    var courseInfo: CourseInfo!
    var courses: [[String: String]]? {
        didSet {
            courseTableView.reloadData()
        }
    }
    var teachWeek = 1
    var week = 1 {
        didSet {
            let chineseWeek = ["日", "一", "二", "三", "四", "五", "六"]
            weekLabel.text = "第\(teachWeek)周 周\(chineseWeek[week])"
        }
    }
    
    @IBAction func changeSchedule(_ sender: Any) {
        if sender is UITapGestureRecognizer {
            (courses, teachWeek, week) = courseInfo.courseDataToday()
        } else {
            let button = sender as! UIButton
            if button.title(for: .normal) == "->" {
                (courses, teachWeek, week) = courseInfo.courseDataNextDay()
            } else {
                (courses, teachWeek, week) = courseInfo.courseDayLastDay()
            }
        }
        loadScheduleData()
    }
    
    @IBAction func awakeHost(_ sender: UIButton) {
        if sender.title(for: .normal) == "未导入课程表" {
            extensionContext?.open(URL(string: "dutinformation://")!, completionHandler: nil)
        } else if sender.title(for: .normal) == "未登录账号" {
            extensionContext?.open(URL(string: "dutinformation://")!, completionHandler: nil)
        }
    }
}

extension TodayViewController: NCWidgetProviding {
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOSApplicationExtension 10.0, *) {
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        if dutInfo != nil {
            return
        }
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        let studentNumber = userDefaults.string(forKey: "StudentNumber")
        let TeachPassword = userDefaults.string(forKey: "TeachPassword")
        let portalPassword = userDefaults.string(forKey: "PortalPassword")
        dutInfo = DUTInfo(studentNumber: studentNumber ?? "",
                          teachPassword: TeachPassword ?? "",
                          portalPassword: portalPassword ?? "")
        dutInfo.delegate = self
        courseInfo = CourseInfo()
        (courses, teachWeek, week) = courseInfo.courseDataToday()
    }
    
    func loadScheduleData() {
        if courses != nil {
            if courses!.count == 0 {
                self.noCourseButton.isHidden = false
                self.noCourseButton.setTitle("今天没有课～", for: .normal)
            } else {
                self.noCourseButton.isHidden = true
            }
            if #available(iOSApplicationExtension 10.0, *) {
                if courses!.count > 1 {
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
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        loadCacheData()
        loadScheduleData()
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
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            preferredContentSize = maxSize
        }
        guard courses != nil else {
            preferredContentSize = CGSize(width: 0, height: 110)
            return
        }
        if activeDisplayMode == .expanded {
            preferredContentSize = CGSize(width: 0,
                                          height: 110 + 61.5 * Double(courses!.count - 1))
        }
        if courses!.count > 0 {
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
    
    func setNetCost(_ netCost: String) {
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
    
    func netErrorHandle(_ error: Error) {
    }
    
    func setSchedule(_ courseArray: [[String : String]]) {}
}

//UITableViewController协议方法
extension TodayViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard courses != nil else {
            return 0
        }
        return courses!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as! CourseCellView
        if #available(iOSApplicationExtension 10.0, *),
            indexPath.row == 0 && extensionContext?.widgetActiveDisplayMode == .compact{
            cell.prepareForNow(fromCourse: courses!, ofIndex: indexPath)
        } else {
            cell.prepare(fromCourse: courses!, ofIndex: indexPath)
        }
        return cell
    }
}
