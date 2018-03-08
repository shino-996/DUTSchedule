//
//  ScheduleViewController.swift
//  DUTInfomation
//
//  Created by shino on 2017/9/13.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit
import DUTInfo

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
        dataSource.freshUIHandler = {
            self.collectionView.reloadData()
        }
        dataSource.data = courseInfo.coursesThisWeek(dataSource.data.date)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if dataSource.data.courses == nil && activityIndicator.isAnimating == false {
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
        if session.isReachable {
            session.sendMessage(["course": courseInfo.allCourseData!], replyHandler: nil, errorHandler: { error in
                print(error)
            })
        }
    }
    
    @IBAction func loadSchedule() {
        activityIndicator.startAnimating()
        DispatchQueue.global().async { [weak self] in
            if self?.dutInfo.loginTeachSite() ?? false {
                self?.courseInfo.allCourseData = self?.dutInfo.courseInfo()
                self?.getScheduleThisWeek()
                DispatchQueue.main.async { [weak self] in
                    self?.loadScheduleButton.isHidden = true
                    self?.activityIndicator.stopAnimating()
                }
            } else {
                self?.performLogin()
            }
        }
    }
    
    @IBAction func changeSchedule(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            getScheduleNextWeek()
        } else if sender.direction == .right {
            getScheduleLastWeek()
        }
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

extension ScheduleViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CourseCell  else {
            return
        }
        guard let courseInfo = cell.courseInfo(courses: dataSource.data.courses, indexPath: indexPath) else {
            return
        }
        let alertController = UIAlertController(title: "课程详情", message: courseInfo, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
}

// 课程表的布局
extension ScheduleViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidthPX = collectionView.bounds.width * UIScreen.main.scale
        var cellWidth: CGFloat = 0
        var cellHeight: CGFloat = 0
        let widthPX = collectionViewWidthPX - 7 * UIScreen.main.scale * 2
        let line = indexPath.item % 8
        let row = Int(indexPath.item / 8)
        if row == 0 {
            cellHeight = 45
            if line == 0 {
                cellWidth = CGFloat(Int(widthPX / 15)) / UIScreen.main.scale
            } else {
                cellWidth = CGFloat(Int(widthPX / 15)) * 2 / UIScreen.main.scale
            }
        } else {
            cellHeight = 85
            if line == 0 {
                cellWidth = CGFloat(Int(widthPX / 15)) / UIScreen.main.scale
            } else {
                cellWidth = CGFloat(Int(widthPX / 15)) * 2 / UIScreen.main.scale
            }
        }
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let collectionViewWidthPX = collectionView.bounds.width * UIScreen.main.scale
        let widthPX = collectionViewWidthPX - 7 * UIScreen.main.scale * 2
        let remindWidth = widthPX - CGFloat(Int(widthPX / 15)) * 15
        let leftPadding = CGFloat(Int(remindWidth / 2)) / UIScreen.main.scale
        let rightPadding = remindWidth / UIScreen.main.scale - leftPadding - 0.001
        return UIEdgeInsets(top: 0, left: leftPadding, bottom: 2, right: rightPadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let cellSpace = CGFloat(2)
        return cellSpace
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let cellSpace = CGFloat(2)
        return cellSpace
    }
}
