//
//  ScheduleViewDataSource.swift
//  DUTInfomation
//
//  Created by shino on 18/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import UIKit

class ScheduleViewDataSource: NSObject, UICollectionViewDataSource {
    var data: (courses: [[String: String]]?, weeknumber: Int, date: Date)
    var controller: TeachWeekDelegate?
    
    init(data: (courses: [[String: String]]?, weeknumber: Int, date: Date)) {
        self.data = data
    }
    
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
                cell.prepare(date: data.date)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekCell", for: indexPath) as! WeekCell
                cell.prepare(date: data.date, indexPath: indexPath)
                return cell
            }
        } else {
            if line == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CourseNumberCell", for: indexPath) as! CourseNumberCell
                cell.prepare(indexPath: indexPath)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CourseCell", for: indexPath) as! CourseCell
                cell.prepare(courses: data.courses, indexPath: indexPath)
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TeachWeekView", for: indexPath) as! TeachWeekView
        view.teachWeekButton.setTitle("第\(data.weeknumber)周", for: .normal)
        view.delegate = controller
        return view
    }
}
