//
//  NotificationCenter+Extension.swift
//  DUTInfomation
//
//  Created by shino on 2018/6/7.
//  Copyright © 2018 shino. All rights reserved.
//

import Foundation

extension NotificationCenter {
    func post(name: String) {
        let notificationName = Notification.Name(rawValue: name)
        let notification = Notification(name: notificationName)
        self.post(notification)
    }
}
