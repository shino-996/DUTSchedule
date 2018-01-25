//
//  AccountViewController.swift
//  DUTInfomation
//
//  Created by shino on 25/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import UIKit

class AccountViewController: UITableViewController {
    var accounts: [[String: String]]?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let accounts = accounts else {
            return 1
        }
        return accounts.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        var cell: UITableViewCell
        if index < accounts!.count {
            let accountCell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as! AccountCell
            accountCell.nameLabel.text = accounts![index]["name"]
            accountCell.numberLabel.text = accounts![index]["number"]
            cell = accountCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "AddAccountCell", for: indexPath)
        }
        return cell
    }
}
