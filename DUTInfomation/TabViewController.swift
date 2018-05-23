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
    var isLogin: Bool = false {
        didSet {
            if isLogin == false {
                performSegue(withIdentifier: "login", sender: self)
            }
        }
    }
    var context: NSManagedObjectContext!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (tabBarController as! TabBarController).isLogin == false {
            performSegue(withIdentifier: "login", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "login" {
            guard let destination = segue.destination as? LoginViewController else {
                fatalError()
            }
            destination.didLogHandler = {
                (self.tabBarController as! TabBarController).isLogin = true
            }
        }
    }
}
