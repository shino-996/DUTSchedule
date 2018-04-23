//
//  TabViewController.swift
//  DUTInfomation
//
//  Created by shino on 14/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import UIKit
import DUTInfo
import CoreData

//所有tab页面的基类
class TabViewController: UIViewController {
    var isLogin: Bool = false
    var context: NSManagedObjectContext!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (tabBarController as! TabBarController).isLogin == false {
            performSegue(withIdentifier: "LoginTeach", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginTeach" {
            let navigation = segue.destination as! UINavigationController
            let destination = navigation.topViewController as! LoginTeachSiteViewController
            destination.didLogHandler = {
                (self.tabBarController as! TabBarController).isLogin = true
            }
        }
    }
}
