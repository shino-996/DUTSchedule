//
//  ScheduleViewController.swift
//  DUTInfomation
//
//  Created by shino on 2017/9/13.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit

class ScheduleViewController: TabViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var teachWeekLabel: UIButton!
    @IBOutlet weak var loadScheduleButton: UIButton!
    var courseInfo: CourseInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        courseInfo = CourseInfo()
        courseInfo.courseDataThisWeek()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if courseInfo.courseData != nil {
            teachWeekLabel.setTitle("第" + courseInfo.teachWeek! + "周", for: .normal)
        } else {
            let alertController = UIAlertController(title: "未导入课表", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
                self.loadScheduleButton.isHidden = false
            }
            let loadAction = UIAlertAction(title: "导入", style: .default) { _ in
                self.loadSchedule()
            }
            alertController.addAction(cancelAction)
            alertController.addAction(loadAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    override func setSchedule(_ courseArray: [[String : String]]) {
        courseInfo.saveCourse(courseArray)
        activityIndicator.stopAnimating()
        loadScheduleButton.isHidden = true
        self.changSchedule(nil)
    }
    
    @IBAction func loadSchedule() {
        dutInfo.loginTeachSite(succeed: {
            self.dutInfo.courseInfo()
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
        }, failed: {
            self.performSegue(withIdentifier: "LoginTeach", sender: self)
        })
    }
    
    @IBAction func changSchedule(_ sender: UIButton?) {
        if let button = sender {
            if button.title(for: .normal)! == "->" {
                courseInfo.courseDataNextWeek()
            } else if button.title(for: .normal) == "<-" {
                courseInfo.courseDataLastWeek()
            }
        } else {
            courseInfo.courseDataThisWeek()
        }
        teachWeekLabel.setTitle("第" + courseInfo.teachWeek! + "周", for: .normal)
        collectionView.reloadData()
    }
}

extension ScheduleViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CourseNumberCell", for: indexPath) as! CourseNumberCell
                cell.prepare(date: courseInfo.date)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekCell", for: indexPath) as! WeekCell
                cell.prepare(date: courseInfo.date, indexPath: indexPath)
                return cell
            }
        } else {
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CourseNumberCell", for: indexPath) as! CourseNumberCell
                cell.prepare(indexPath: indexPath)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CourseCell", for: indexPath) as! CourseCell
                cell.prepare(courseData: courseInfo.courseData, indexPath: indexPath)
                return cell
            }
        }
    }
}

extension ScheduleViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidthPX = collectionView.bounds.width * UIScreen.main.scale
        var cellWidth: CGFloat = 0
        var cellHeight: CGFloat = 0
        let widthPX = collectionViewWidthPX - 7
        if indexPath.section == 0 {
            cellHeight = 40
            if indexPath.item == 0 {
                cellWidth = CGFloat(Int(widthPX / 15)) / UIScreen.main.scale
            } else {
                cellWidth = CGFloat(Int(widthPX / 15)) * 2 / UIScreen.main.scale
            }
        } else {
            cellHeight = 80
            if indexPath.item == 0 {
                cellWidth = CGFloat(Int(widthPX / 15)) / UIScreen.main.scale
            } else {
                cellWidth = CGFloat(Int(widthPX / 15)) * 2 / UIScreen.main.scale
            }
        }
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let collectionViewWidthPX = collectionView.bounds.width * UIScreen.main.scale
        let widthPX = collectionViewWidthPX - 7
        let remindWidth = widthPX - CGFloat(Int(widthPX / 15)) * 15
        let leftPadding = CGFloat(Int(remindWidth / 2)) / UIScreen.main.scale
        let rightPadding = remindWidth / UIScreen.main.scale - leftPadding - 0.001
        return UIEdgeInsets(top: 0, left: leftPadding, bottom: 1 / UIScreen.main.scale, right: rightPadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let cellSpace = 1 / UIScreen.main.scale
        return cellSpace
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let cellSpace = 1 / UIScreen.main.scale
        return cellSpace
    }
}
