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
    @IBOutlet weak var noCourseLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var courseTableView: UITableView!
    @IBOutlet weak var weekLabel: UILabel!
    
    fileprivate lazy var dutInfo: DUTInfo! = DUTInfo(())
    var scheduleDate = Date()
    var courseInfo: [[String: String]]!
    var freshingNum: Int! {
        didSet {
            if freshingNum <= 0 {
                activityIndicator.stopAnimating()
                let now = Date().timeIntervalSince1970
                let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
                userDefaults.set(now, forKey: "LastUpdateDate")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadScheduleData()
        if #available(iOSApplicationExtension 10.0, *) {
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        freshWeekLabel()
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.preferredContentSize = maxSize
        } else {
            self.preferredContentSize = CGSize(width: 0, height: 110 + 61.5 * Double(courseInfo.count - 1))
        }
        guard courseInfo != nil else {
            return
        }
        if courseInfo.count != 0 {
            let index = IndexPath(item: 0, section: 0)
            courseTableView.reloadRows(at: [index], with: .automatic)
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        var result = NCUpdateResult.failed
        if dutInfo == nil {
            print("need to login")
        } else {
            dutInfo.delegate = self
            if isTimeToFresh() {
                result = .newData
                freshData()
            } else {
                result = .noData
                loadCacheData()
            }
        }
        completionHandler(result)
    }
    
    func freshWeekLabel() {
        let chineseWeek = ["日", "一", "二", "三", "四", "五", "六"]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "e"
        let week = chineseWeek[Int(dateFormatter.string(from: scheduleDate))! - 1]
        dateFormatter.dateFormat = "w"
        let weeknumber = Int(dateFormatter.string(from: scheduleDate))! - 35
        weekLabel.text = "第\(weeknumber)周 周\(week)"
    }

    @IBAction func moveSchedule(_ sender: Any) {
        let gestureRecognizer = sender as! UITapGestureRecognizer
        let point = gestureRecognizer.location(in: view)
        if point.x < 70 {
            scheduleDate = scheduleDate.addingTimeInterval(-60 * 60 * 24)
            loadSchedule(ofDate: scheduleDate)
            courseTableView.reloadData()
        } else if point.x > view.frame.width - 70 {
            scheduleDate = scheduleDate.addingTimeInterval(60 * 60 * 24)
            loadSchedule(ofDate: scheduleDate)
            courseTableView.reloadData()
        }
        freshWeekLabel()
    }
    
    @IBAction func backTodaySchedule(_ sender: Any) {
        let gestureRecognizer = sender as! UITapGestureRecognizer
        let point = gestureRecognizer.location(in: view)
        if point.x >= 70 && point.x <= view.frame.width - 70 {
            scheduleDate = Date()
            loadScheduleData()
            courseTableView.reloadData()
            freshWeekLabel()
        }
    }
}

extension TodayViewController {
    func loadScheduleData() {
        loadSchedule(ofDate: scheduleDate)
    }
    
    func loadSchedule(ofDate date: Date) {
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")
        let fileURL = groupURL!.appendingPathComponent("course.plist")
        let array = NSArray(contentsOf: fileURL)
        guard array != nil else {
            courseInfo = []
            return
        }
        let courseData = array as! [[String: String]]
        let weekDateFormatter = DateFormatter()
        weekDateFormatter.dateFormat = "e"
        let week = String(Int(weekDateFormatter.string(from: date))! - 1)
        let weeknumberDateFormatter = DateFormatter()
        weeknumberDateFormatter.dateFormat = "w"
        let weeknumber = Int(weeknumberDateFormatter.string(from: date))! - 35
        courseInfo = courseData.filter { (course: [String: String]) -> Bool in
            let weekStr = course["week"]!
            if String(weekStr) != week {
                return false
            }
            let weeknumberStr = course["weeknumber"]!.components(separatedBy: "-")
            let startWeek = Int(weeknumberStr[0])!
            let endWeek = Int(weeknumberStr[1])!
            if weeknumber >= startWeek && weeknumber <= endWeek {
                return true
            } else {
                return false
            }
        }.sorted {
            $0["coursenumber"]! <= $1["coursenumber"]!
        }
    }
    
    func loadCacheData() {
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        ecardLabel.text = userDefaults.string(forKey: "EcardCost")
        if let netCost = userDefaults.string(forKey: "NetCost"),
            let netFlow = userDefaults.string(forKey: "NetFlow") {
            netLabel.text = netCost + "/" + netFlow
        } else {
            netLabel.text = ""
        }
    }
    
    func isTimeToFresh() -> Bool {
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        let lastUpdateDate = userDefaults.double(forKey: "LastUpdateDate")
        guard lastUpdateDate != 0 else {
            return true
        }
        let now = Date().timeIntervalSince1970
        if now - lastUpdateDate < 1800 {
            return false
        } else {
            return true
        }
    }
    
    func freshData() {
        activityIndicator.startAnimating()
        freshingNum = 3
        dutInfo.ecardInfo()
        dutInfo.netInfo()
    }
}

extension TodayViewController: DUTInfoDelegate {
    func setEcardCost() {
        DispatchQueue.main.async {
            self.ecardLabel.text = self.dutInfo.ecardCost
        }
        freshingNum = freshingNum - 1
    }
    
    func setNetCost() {
        freshingNum = freshingNum - 1
    }
    
    func setNetFlow() {
        DispatchQueue.main.async {
            self.netLabel.text = self.dutInfo.netFlow + "/" + self.dutInfo.netCost
        }
        freshingNum = freshingNum - 1
    }
    
    func netErrorHandle() {
        freshingNum = freshingNum - 2
    }
}

extension TodayViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if courseInfo.count == 0 {
            noCourseLabel.isHidden = false
        } else {
            noCourseLabel.isHidden = true
        }
        if #available(iOSApplicationExtension 10.0, *) {
            if courseInfo.count > 1 {
                extensionContext?.widgetLargestAvailableDisplayMode = .expanded
            } else {
                extensionContext?.widgetLargestAvailableDisplayMode = .compact
            }
        }
        return courseInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as! CourseCellView
        if #available(iOSApplicationExtension 10.0, *),
            indexPath.row == 0 && extensionContext?.widgetActiveDisplayMode == .compact{
            cell.prepareForNow(fromCourse: courseInfo, ofIndex: indexPath)
        } else {
            cell.prepare(fromCourse: courseInfo, ofIndex: indexPath)
        }
        return cell
    }
}
