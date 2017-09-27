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
    @IBOutlet weak var noCourseLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var courseTableView: UITableView!
    @IBOutlet weak var weekLabel: UILabel!
    
    var dutInfo: DUTInfo!
    var courseInfo: CourseInfo!
    var scheduleDate = Date()
    var freshingNum: Int! {
        didSet {
            if freshingNum <= 0 {
                activityIndicator.stopAnimating()
            }
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
        dutInfo.login(succeed: {
            self.courseInfo = CourseInfo(dutInfo: self.dutInfo)
            self.courseInfo.delegate = self
            self.courseInfo.getCourseData()
        }, failed: {
            self.noCourseLabel.isHidden = false
            self.noCourseLabel.text = "尚未登录账户"
        })
    }
    
    @IBAction func moveSchedule(_ sender: Any) {
        let gestureRecognizer = sender as! UITapGestureRecognizer
        let point = gestureRecognizer.location(in: view)
        if point.x < 70 {
            courseInfo.getPreviousDayCourseData()
        } else if point.x > view.frame.width - 70 {
            courseInfo.getNextDayCourseData()
        }
    }
    
    @IBAction func backTodaySchedule(_ sender: Any) {
        let gestureRecognizer = sender as! UITapGestureRecognizer
        let point = gestureRecognizer.location(in: view)
        if point.x >= 70 && point.x <= view.frame.width - 70 {
            courseInfo.getTodayCourseData()
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        loadCacheData()
        activityIndicator.startAnimating()
        freshingNum = 3
        dutInfo.newPortalNetInfo()
        completionHandler(.noData)
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.preferredContentSize = maxSize
        } else {
            self.preferredContentSize = CGSize(width: 0,
                                               height: 110 + 61.5 * Double(courseInfo.courseData.count - 1))
        }
        guard courseInfo?.courseData != nil else {
            return
        }
        if courseInfo.courseData.count > 0 {
            let index = IndexPath(item: 0, section: 0)
            courseTableView.reloadRows(at: [index], with: .automatic)
        }
    }
}

//刷新相关函数
extension TodayViewController {
    func loadCacheData() {
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        ecardLabel.text = userDefaults.string(forKey: "EcardCost")
        if let netCost = userDefaults.string(forKey: "NetCost"),
            let netFlow = userDefaults.string(forKey: "NetFlow") {
            netLabel.text = netFlow + "/" + netCost
        } else {
            netLabel.text = ""
        }
    }
}

extension TodayViewController: DUTInfoDelegate {
    func setEcardCost(_ ecardCost: String) {
        DispatchQueue.main.async {
            self.ecardLabel.text = ecardCost
        }
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        userDefaults.set(ecardCost, forKey: "EcardCost")
        freshingNum = freshingNum - 1
    }
    
    func setNetCost(_ netCost: String) {
        freshingNum = freshingNum - 1
    }
    
    func setNetFlow(_ netFlow: String) {
        DispatchQueue.main.async {
            self.netLabel.text = netFlow + "/" + self.dutInfo.netCost
        }
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        userDefaults.set(dutInfo.netCost, forKey: "NetCost")
        userDefaults.set(netFlow, forKey: "NetFlow")
        freshingNum = freshingNum - 1
    }
    
    func netErrorHandle() {
        freshingNum = freshingNum - 2
    }
    
    func setSchedule(_ courseArray: [[String : String]]) {
        courseInfo.allCourseData = courseArray
    }
}

extension TodayViewController: CourseInfoDelegate {
    func courseDidSet(courses: [[String : String]], week: String) {}
    
    func courseDidChange(courses: [[String : String]], week: String) {
        courseTableView.reloadData()
        DispatchQueue.main.async {
            self.weekLabel.text = week
        }
        if courses.count == 0 {
            noCourseLabel.isHidden = false
            noCourseLabel.text = "今天没有课～"
        } else {
            noCourseLabel.isHidden = true
        }
        if #available(iOSApplicationExtension 10.0, *) {
            if courses.count > 1 {
                extensionContext?.widgetLargestAvailableDisplayMode = .expanded
            } else {
                extensionContext?.widgetLargestAvailableDisplayMode = .compact
            }
        }
    }
}

//UITableViewController协议方法
extension TodayViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard courseInfo?.courseData != nil else {
            return 0
        }
        return courseInfo.courseData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as! CourseCellView
        if #available(iOSApplicationExtension 10.0, *),
            indexPath.row == 0 && extensionContext?.widgetActiveDisplayMode == .compact{
            cell.prepareForNow(fromCourse: courseInfo.courseData, ofIndex: indexPath)
        } else {
            cell.prepare(fromCourse: courseInfo.courseData, ofIndex: indexPath)
        }
        return cell
    }
}
