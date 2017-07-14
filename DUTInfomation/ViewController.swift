//
//  ViewController.swift
//  DUTInfomation
//
//  Created by shino on 2017/7/3.
//  Copyright © 2017年 shino. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SimplePingDelegate {
    var dutInfo: DUTInfo!
    var pinger: SimplePing!
    var pingLoopTimer: Timer!
    var pingErrorTimer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        dutInfo = DUTInfo()
        dutInfo.studentNumber = "学号"
        dutInfo.teachPassword = "教务处密码"
        dutInfo.portalPassword = "校园门户密码"
        pinger = SimplePing(hostName: "202.118.74.160")
        pinger.addressStyle = .icmPv4
        pinger.delegate = self
        pinger.start()
        pingLoopTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(pingLoop), userInfo: nil, repeats: true)
        pingErrorTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(pingError), userInfo: nil, repeats: false)
//        dutInfo.scheduleInfo()
//        dutInfo.gradeInfo()
//        dutInfo.ecardInfo()
    }
    
    func pingLoop() {
        pinger.send(with: nil)
    }
    
    func pingError() {
        pinger.stop()
        pingLoopTimer.invalidate()
        print("请在校园网环境下查询所有信息")
    }
    
    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        pinger.stop()
        pingLoopTimer.invalidate()
        pingErrorTimer.invalidate()
        dutInfo.netInfo()
    }
}

