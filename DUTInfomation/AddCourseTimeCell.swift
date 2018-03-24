//
//  AddCourseTimeCell.swift
//  DUTInfomation
//
//  Created by shino on 24/03/2018.
//  Copyright © 2018 shino. All rights reserved.
//

import UIKit

class AddCourseTimeCell: UITableViewCell {
    @IBOutlet weak var weekSegment: UISegmentedControl!
    @IBOutlet weak var coursenumberText: UITextField!
    @IBOutlet weak var weeknumberText: UITextField!
    
    func courseText() -> [String: String] {
        return ["week": String(weekSegment.selectedSegmentIndex),
                "coursenumber": coursenumberText.text ?? "1",
                "weeknumber": weeknumberText.text ?? "1-1"]
    }
}
