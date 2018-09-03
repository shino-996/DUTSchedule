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
}

// 课程加载与刷新
extension ScheduleViewController {
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
        
        notificationCenter.addObserver(forName: "space.shino.post.logined") { [weak self] _ in
            self?.activityIndicator.startAnimating()
            DispatchQueue.global().async {
                self?.dataManager.load([.course])
            }
        }
        
        notificationCenter.addObserver(forName: "space.shino.post.course") { [weak self] _ in
            let date = Date()
            guard let courses = self?.dataManager.courses(of: .thisWeek(date)) else {
                return
            }
            self?.dataSource.courses = courses
            self?.dataSource.date = date
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.collectionView.reloadData()
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

// 课程添加与删除
extension ScheduleViewController {
    
}

// 课程表上的点击事件
extension ScheduleViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 不是课程的 cell 不进行处理
        guard let cell = collectionView.cellForItem(at: indexPath) as? CourseCell  else {
            return
        }
        if let courseInfo = cell.courseInfo(courses: dataSource.courses, indexPath: indexPath) {
            // 如果上面有显示课程, 弹出课程详请
            let alertController = UIAlertController(title: "课程详情", message: courseInfo, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
        } else {
            // 如果没有显示课程, 添加课程
            if cell.addLabel.isHidden == true {
                // 如果添加按钮没显示, 将其显示出来, 防止误触
                NotificationCenter.default.post(name: "space.shino.post.addcourse")
                cell.backgroundColor = UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.7)
                cell.addLabel.isHidden = false
            } else {
                // 弹出添加课程界面
                NotificationCenter.default.addObserver(forName: "space.shino.post.addcourseresult") { [unowned self] info in
                    guard let courseData = info.userInfo?["course"] as? Data else {
                        return
                    }
                    self.dataManager.addCourse(fromJson: courseData)
                    self.getScheduleThisWeek()
                }
                performSegue(withIdentifier: "addCourse", sender: nil)
            }
        }
    }
}
