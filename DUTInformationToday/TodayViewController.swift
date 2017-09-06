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
    
    var courseInfo: [[String: String]]!
    
    var dutInfo: DUTInfo!
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
    
    func loadCacheData() {
        let userDefaults = UserDefaults(suiteName: "group.dutinfo.shino.space")!
        ecardLabel.text = userDefaults.string(forKey: "EcardCost")
        if let netCost = userDefaults.string(forKey: "NetCost"),
            let netFlow = userDefaults.string(forKey: "NetFlow") {
            netLabel.text = netCost + "/" + netFlow
        } else {
            netLabel.text = ""
        }
        if courseInfo.count == 0 {
            noCourseLabel.isHidden = false
        } else {
            noCourseLabel.isHidden = true
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
        dutInfo = DUTInfo()
        dutInfo.studentNumber = "201487033"
        dutInfo.teachPassword = "220317"
        dutInfo.portalPassword = "shino$sshLoca1"
        dutInfo.delegate = self
        activityIndicator.startAnimating()
        freshingNum = 3
        dutInfo.ecardInfo()
        dutInfo.netInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOSApplicationExtension 10.0, *) {
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.preferredContentSize = maxSize
        } else {
            self.preferredContentSize = CGSize(width: 0, height: 110 + 61.5 * Double(courseInfo.count - 1))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")
        let fileURL = groupURL!.appendingPathComponent("course.plist")
        let courseData = NSArray(contentsOf: fileURL) as! [[String: String]]
        let date = Date()
        let weekDateFormatter = DateFormatter()
        weekDateFormatter.dateFormat = "e"
        let week = String(Int(weekDateFormatter.string(from: date))! - 1)
        let weeksDateFormatter = DateFormatter()
        weeksDateFormatter.dateFormat = "w"
        let weeks = Int(weeksDateFormatter.string(from: date))! - 35
        courseInfo = courseData.filter { (course: [String: String]) -> Bool in
            let weekStr = course["week"]!
            let index = weekStr.index(weekStr.startIndex, offsetBy: 1)
            if String(weekStr[index]) != week {
                return false
            }
            let weeksStr = course["weeks"]!.components(separatedBy: "-")
            let startWeek = Int(weeksStr[0])!
            let endWeekUtils = weeksStr[1]
            let endWeekIndex = endWeekUtils.index(endWeekUtils.endIndex, offsetBy: -1)
            let endWeek = Int(endWeekUtils.substring(to: endWeekIndex))!
            if weeks >= startWeek && weeks <= endWeek {
                return true
            } else {
                return false
            }
        }.sorted {
            $0["week"]! <= $1["week"]!
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        var result = NCUpdateResult.failed
        loadCacheData()
        if isTimeToFresh() {
            result = .newData
            freshData()
        }
        completionHandler(result)
    }
    
    @IBAction func forceFreshData() {
        freshData()
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
        return courseInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath)
                    as! CourseCellView
        let index = indexPath.row
        cell.name.text = courseInfo[index]["name"]!
        cell.teacher.text = courseInfo[index]["teacher"]!
        let placeStr = courseInfo[index]["place"]!
        let placeStrIndex = placeStr.index(placeStr.startIndex, offsetBy: 2)
        cell.place.text = placeStr.substring(from: placeStrIndex)
        let weekStr = courseInfo[index]["week"]!
        let weekStrIndex = weekStr.index(weekStr.startIndex, offsetBy: 4)
        cell.week.text = weekStr.substring(from: weekStrIndex)
        return cell
    }
}
