//
//  TeachWeekView.swift
//  DUTInfomation
//
//  Created by shino on 17/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import UIKit

class TeachWeekView: UICollectionReusableView {
    
    @IBOutlet weak var teachWeekButton: UIButton!
    @IBAction func changeSchedule(_ sender: UIButton) {
        let title = sender.title(for: .normal) ?? ""
        var notificationName: String
        if title == "⇨" {
            notificationName = "space.shino.post.nextweek"
        } else if title == "⇦" {
            notificationName = "space.shino.post.lastweek"
        } else {
            notificationName = "space.shino.post.thisweek"
        }
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: notificationName)))
    }
}
