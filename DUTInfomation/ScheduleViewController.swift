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
        dataSource = ScheduleViewDataSource(courses: courses, date: date)
        collectionView.dataSource = dataSource
        addObserver()
    }
    
    func addObserver() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(getScheduleThisWeek),
                                               name: Notification.Name(rawValue: "space.shino.post.thisweek"),
                                               object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(getScheduleNextWeek),
                                               name: Notification.Name(rawValue: "space.shino.post.nextweek"),
                                               object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(getScheduleLastWeek),
                                               name: Notification.Name(rawValue: "space.shino.post.lastweek"),
                                               object: nil)
        
        notificationCenter.addObserver(forName: Notification.Name(rawValue: "space.shino.post.logined"),
                                       object: nil,
                                       queue: nil) { _ in
            self.activityIndicator.startAnimating()
            DispatchQueue.global().async {
                self.dataManager.load([.course])
            }
        }
        
        notificationCenter.addObserver(forName: Notification.Name(rawValue: "space.shino.post.course"),
                                       object: nil,
                                       queue: nil) { _ in
            let date = Date()
            self.dataSource.courses = self.dataManager.courses(of: .thisWeek(date))
            self.dataSource.date = date
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.collectionView.reloadData()
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
