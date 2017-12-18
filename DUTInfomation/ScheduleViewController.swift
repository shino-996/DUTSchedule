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
    @IBOutlet weak var loadScheduleButton: UIButton!
    var courseInfo: CourseInfo!
    var courses: [[String: String]]? {
        didSet {
            collectionView.reloadData()
        }
    }
    var teachWeek = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        courseInfo = CourseInfo()
        (courses, teachWeek) = courseInfo.courseDataThisWeek()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if courses == nil {
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
        courseInfo.allCourseData = courseArray
        activityIndicator.stopAnimating()
        loadScheduleButton.isHidden = true
        self.getScheduleThisWeek()
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
}

extension ScheduleViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (7 + 1) * (8 + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let line = indexPath.item % 8
        let row = Int(indexPath.item / 8)
        if row == 0 {
            if line == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CourseNumberCell", for: indexPath) as! CourseNumberCell
                cell.prepare(date: courseInfo.date)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekCell", for: indexPath) as! WeekCell
                cell.prepare(date: courseInfo.date, indexPath: indexPath)
                return cell
            }
        } else {
            if line == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CourseNumberCell", for: indexPath) as! CourseNumberCell
                cell.prepare(indexPath: indexPath)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CourseCell", for: indexPath) as! CourseCell
                cell.prepare(courseData: courses, indexPath: indexPath)
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TeachWeekView", for: indexPath) as! TeachWeekView
        view.teachWeekButton.setTitle("第\(teachWeek)周", for: .normal)
        view.delegate = self
        return view
    }
}

extension ScheduleViewController: TeachWeekDelegate {
    func getScheduleThisWeek() {
        (courses, teachWeek) = courseInfo.courseDataThisWeek()
    }
    
    func getScheduleNextWeek() {
        (courses, teachWeek) = courseInfo.courseDataNextWeek()
    }
    
    func getScheduleLastWeek() {
        (courses, teachWeek) = courseInfo.courseDataLastWeek()
    }
}

// 课程表的布局
extension ScheduleViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidthPX = collectionView.bounds.width * UIScreen.main.scale
        var cellWidth: CGFloat = 0
        var cellHeight: CGFloat = 0
        let widthPX = collectionViewWidthPX - 7
        let line = indexPath.item % 8
        let row = Int(indexPath.item / 8)
        if row == 0 {
            cellHeight = 40
            if line == 0 {
                cellWidth = CGFloat(Int(widthPX / 15)) / UIScreen.main.scale
            } else {
                cellWidth = CGFloat(Int(widthPX / 15)) * 2 / UIScreen.main.scale
            }
        } else {
            cellHeight = 80
            if line == 0 {
                cellWidth = CGFloat(Int(widthPX / 15)) / UIScreen.main.scale
            } else {
                cellWidth = CGFloat(Int(widthPX / 15)) * 2 / UIScreen.main.scale
            }
        }
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 20)
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
