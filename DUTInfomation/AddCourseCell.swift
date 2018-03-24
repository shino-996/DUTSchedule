//
//  AddCourseCell.swift
//  DUTInfomation
//
//  Created by shino on 23/03/2018.
//  Copyright © 2018 shino. All rights reserved.
//

import UIKit

class AddCourseCell: UITableViewCell {
    @IBOutlet weak var courseInfoText: UITextField!
    
    func prepare(_ string: String) {
        courseInfoText.placeholder = string
    }
}
