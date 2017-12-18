//
//  ScheduleViewController.swift
//  DUTInfomation
//
//  Created by shino on 2017/9/13.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit

class ScheduleViewController: TabViewController, TeachWeekDelegate {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadScheduleButton: UIButton!
    var courseInfo: CourseInfo!
    var dataSource: ScheduleViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        courseInfo = CourseInfo()
        dataSource = ScheduleViewDataSource()
        collectionView.dataSource = dataSource
        dataSource.controller = self
        dataSource.freshUIHandler = { [unowned self] in
            self.collectionView.reloadData()
        }
        dataSource.data = courseInfo.coursesThisWeek(dataSource.data.date)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if dataSource.data.courses == nil {
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
    
    func getScheduleThisWeek() {
        dataSource.data  = courseInfo.coursesThisWeek(Date())
    }
    
    func getScheduleNextWeek() {
        dataSource.data = courseInfo.coursesNextWeek(dataSource.data.date)
    }
    
    func getScheduleLastWeek() {
        dataSource.data = courseInfo.coursesLastWeek(dataSource.data.date)
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
