//
//  TeachWeekView.swift
//  DUTInfomation
//
//  Created by shino on 17/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import UIKit

protocol TeachWeekDelegate: AnyObject {
    weak var collectionView: UICollectionView! { get }
    func getScheduleThisWeek()
    func getScheduleNextWeek()
    func getScheduleLastWeek()
}

class TeachWeekView: UICollectionReusableView {
    weak var delegate: TeachWeekDelegate?
    
    @IBOutlet weak var teachWeekButton: UIButton!
    @IBAction func changeSchedule(_ sender: UIButton) {
        let title = sender.title(for: .normal) ?? ""
        if title == "⇨" {
            delegate?.getScheduleNextWeek()
        } else if title == "⇦" {
            delegate?.getScheduleLastWeek()
        } else {
            delegate?.getScheduleThisWeek()
        }
    }
}
