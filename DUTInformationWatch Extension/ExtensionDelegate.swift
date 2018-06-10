//
//  ExtensionDelegate.swift
//  DUTInformationWatch Extension
//
//  Created by shino on 08/03/2018.
//  Copyright © 2018 shino. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    var dataManager: DataManager? = {
        if UserInfo.shared.getAccount() != nil {
            return DataManager()
        } else {
            return nil
        }
    }()
    
    var handler: (() -> Void)?
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                if (backgroundTask.userInfo as? [String: String] ?? [:])["tag"] == "fetchbackground" {
                    if let dataManager = dataManager {
                        DispatchQueue.global().async {
                            dataManager.load([.net, .ecard])
                            let userInfo = ["tag": "finishfetch"] as NSDictionary
                            WKExtension.shared().scheduleSnapshotRefresh(withPreferredDate: Date(),
                                                                         userInfo: userInfo) { error in
                                if let error = error {
                                    print(error)
                                }
                            }
                            self.fetchInfoBackground(interval: Date(timeIntervalSinceNow: 60 * 30))
                        }
                    } else {
                        fetchInfoBackground(interval: Date(timeIntervalSinceNow: 10))
                    }
                }
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                if let userInfo = snapshotTask.userInfo as? [String: String] {
                    if userInfo["tag"] ?? "" == "finishfetch" {
                        handler?()
                    }
                }
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

    func fetchInfoBackground(interval: Date = Date()) {
        let userInfo = ["tag": "fetchbackground"] as NSDictionary
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: interval, userInfo: userInfo) { error in
            if let error = error {
                print("watch fetch background error")
                print(error)
            }
        }
    }
}
