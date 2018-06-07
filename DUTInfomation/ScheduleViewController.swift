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
    var dataSource: ScheduleViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let date = Date()
        let courses = dataManager.courses(of: .thisWeek(date))
        if courses.count == 0 {
            loadSchedule()
        }
        dataSource = ScheduleViewDataSource(courses: courses, date: date)
        collectionView.dataSource = dataSource
        addObserver()
    }
    
    func addObserver() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(forName: Notification.Name(rawValue: "space.shino.post.course"),
                                               object: nil,
                                               queue: nil) { _ in
            let date = Date()
            self.dataSource.courses = self.dataManager.courses(of: .thisWeek(date))
            self.dataSource.date = date
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        notificationCenter.addObserver(self, selector: #selector(getScheduleThisWeek),
                                               name: Notification.Name(rawValue: "space.shino.post.thisweek"),
                                               object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(getScheduleNextWeek),
                                               name: Notification.Name(rawValue: "space.shino.post.nextweek"),
                                               object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(getScheduleLastWeek),
                                               name: Notification.Name(rawValue: "space.shino.post.lastweek"),
                                               object: nil)
    }
    
    func loadSchedule() {
        activityIndicator.startAnimating()
        DispatchQueue.global().async {
            self.dataManager.load([.course])
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
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
    
    @objc func getScheduleThisWeek() {
        let date = dataSource.date
        dataSource.courses = dataManager.courses(of: .thisWeek(date))
        collectionView.reloadData()
    }
    
    @objc func getScheduleNextWeek() {
        let date = dataSource.date
        dataSource.courses = dataManager.courses(of: .nextWeek(date))
        dataSource.date = date.nextWeek()
        collectionView.reloadData()
    }
    
    @objc func getScheduleLastWeek() {
        let date = dataSource.date
        dataSource.courses = dataManager.courses(of: .lastWeek(date))
        dataSource.date = date.lastWeek()
        collectionView.reloadData()
    }
}

extension ScheduleViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CourseCell  else {
            return
        }
        guard let courseInfo = cell.courseInfo(courses: dataSource.courses, indexPath: indexPath) else {
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
