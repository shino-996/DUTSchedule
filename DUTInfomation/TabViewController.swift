//
//  TabViewController.swift
//  DUTInfomation
//
//  Created by shino on 14/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import UIKit
import CoreData

//所有tab页面的基类
class TabViewController: UIViewController {
    var dataManager: DataManager!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UserInfo.shared.isLogin {
            performSegue(withIdentifier: "Login", sender: self)
        }
    }
}
