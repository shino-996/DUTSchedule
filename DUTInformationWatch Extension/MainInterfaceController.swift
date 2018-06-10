//
//  MainInterfaceController.swift
//  DUTInformationWatch Extension
//
//  Created by shino on 08/03/2018.
//  Copyright © 2018 shino. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import CoreData

enum RowType: String {
    case SyncRow
    case NetRow
    case EcardRow
    case CourseRow
    case MoreCourseRow
}

class MainInterfaceController: WKInterfaceController {
    @IBOutlet var informationTable: WKInterfaceTable!
    @IBOutlet var updateLabel: WKInterfaceLabel!
    
    let session = WCSession.default
    var dataManager: DataManager?
    var rowTypes: [RowType] = []
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if UserInfo.shared.isLogin {
            prepareData()
        } else {
            syncFromPhone()
        }
    }
    
    override func willActivate() {
        addObserver()
    }
    
    override func willDisappear() {
        NotificationCenter.default.removeObserver(self)
    }
}

// 同步数据后的初始化
extension MainInterfaceController {
    func prepareData() {
        dataManager = DataManager()
        guard let delegate = WKExtension.shared().delegate as? ExtensionDelegate else {
            fatalError("WKExtension delegate type error")
        }
        delegate.dataManager = dataManager
        delegate.handler = { [weak self] in
            DispatchQueue.main.async {
                self?.freshUI()
            }
        }
        startFetchBackground()
        freshUI()
    }
    
    func addObserver() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self,
                                       selector: #selector(freshNetUI),
                                       name: Notification.Name(rawValue: "space.shino.post.net"),
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(freshEcardUI),
                                       name: Notification.Name(rawValue: "space.shino.post.ecard"),
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(freshComplication),
                                       name: Notification.Name(rawValue: "space.shino.post.net"),
                                       object: nil)
    }
    
    func startFetchBackground() {
        let userInfo = ["tag": "fetchbackground"] as NSDictionary
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(), userInfo: userInfo) { error in
            if let error = error {
                print("watch fetch background error")
                print(error)
            }
        }
    }
}

// 视图切换
extension MainInterfaceController {
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if rowTypes[rowIndex] == .CourseRow {
            let course = (table.rowController(at: rowIndex) as! CourseRow).course!
            presentController(withName: "CourseInterface", context: course.course)
        } else if rowTypes[rowIndex] == .MoreCourseRow {
            pushController(withName: "ScheduleInterface", context: dataManager)
        }
    }
}

// UI更新
extension MainInterfaceController {
    @objc func freshNetUI() {
        let netRow = informationTable.rowController(at: rowTypes.firstIndex(of: .NetRow)!) as! NetRow
        if let net = dataManager?.net() {
            netRow.prepare(cost: net.costStr(), flow: net.flowStr())
        }
    }
    
    @objc func freshEcardUI() {
        let ecardRow = informationTable.rowController(at: rowTypes.firstIndex(of: .EcardRow)!) as! EcardRow
        if let ecard = dataManager?.ecard() {
            ecardRow.prepare(ecard.ecardStr())
        }
    }
    
    @objc func freshComplication() {
        let complicationServer = CLKComplicationServer.sharedInstance()
        if let complications = complicationServer.activeComplications {
            for complication in complications {
                complicationServer.reloadTimeline(for: complication)
            }
        }
    }
    
    func freshUI() {
        rowTypes = [.NetRow, .EcardRow]
        let courses = dataManager!.courses(of: .today(Date()))
        let courseRows = courses.map { _ in return RowType.CourseRow }
        rowTypes.append(contentsOf: courseRows)
        rowTypes.append(.MoreCourseRow)
        informationTable.setRowTypes(rowTypes.map { $0.rawValue })
        
        freshNetUI()
        freshEcardUI()
        freshComplication()
        
        if let startIndex = rowTypes.firstIndex(of: .CourseRow),
            let endIndex = rowTypes.lastIndex(of: .CourseRow) {
            var courseIndex = 0
            for i in startIndex ... endIndex {
                let courseRow = informationTable.rowController(at: i) as! CourseRow
                courseRow.prepare(course: courses[courseIndex])
                courseIndex += 1
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm"
        updateLabel.setText("更新时间:" + dateFormatter.string(from: Date()))
    }
}

// 与手机同步数据, 直接同步 CoreData 中的 sqlite3 文件
extension MainInterfaceController: WCSessionDelegate {
    func syncFromPhone() {
        rowTypes = [.SyncRow]
        informationTable.setRowTypes(rowTypes.map { $0.rawValue })
        session.delegate = self
        session.activate()
    }
    
    // 主动请求与手机连接
    func requestSync() {
        if UserInfo.shared.isLogin {
            return
        }
        let message = ["message": "sync request"]
            session.sendMessage(message, replyHandler: nil) { error in
                print("Watch request error!")
                print(error)
            }
    }
    
    // 收到手机的连接请求, 进宪回复
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        requestSync()
    }
    
    // 收到手机发来的数据
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if UserInfo.shared.isLogin {
            return
        }
        if (message["message"] as? String) == "sync request" {
            requestSync()
            return
        }
        if let syncData = message["syncdata"] as? [String: Any] {
            let keys = syncData["keys"] as! [String: String]
            let studentNumber = keys["studentnumber"]!
            let password = keys["password"]!
            UserInfo.shared.setAccount(studentNumber: studentNumber, password: password)
            
            let data = syncData["data"] as! Data
            let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dutinfo.shino.space")!
            let url = groupURL.appendingPathComponent("dutinfo.data")
            do {
                try data.write(to: url)
            } catch(let error) {
                print(error)
                fatalError()
            }
            prepareData()
        }
    }
}
