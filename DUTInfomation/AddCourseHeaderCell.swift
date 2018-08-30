//
//  AddCourseHeaderCell.swift
//  DUTInfomation
//
//  Created by shino on 2018/8/30.
//  Copyright © 2018年 shino. All rights reserved.
//

import UIKit

class AddCourseHeaderCell: UITableViewCell {
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func deleteSection() {
        NotificationCenter.default.post(name: "space.shino.post.deletecoursecell")
    }
}
