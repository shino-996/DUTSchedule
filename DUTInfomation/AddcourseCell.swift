//
//  AddcourseCell.swift
//  DUTInfomation
//
//  Created by shino on 2018/8/30.
//  Copyright © 2018年 shino. All rights reserved.
//

import UIKit

class AddcourseCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var content: UITextField!
    var type: InputType!
    var formatCorrect = false
    
    enum InputType: Int {
        case place = 1
        case startweek = 2
        case endweek = 3
        case weekday = 4
        case startsection = 5
        case endsection = 6
    }
    
    func prepare(_ indexPath: IndexPath) {
        type = InputType(rawValue: indexPath.row)
        if type == nil {
            fatalError("AddCourseCell type error")
        }
        var labelText: String
        switch type! {
        case .place:
            labelText = "上课地点"
        case .startweek:
            labelText = "起始周数"
        case .endweek:
            labelText = "结束周数"
        case .weekday:
            labelText = "上课星期"
        case .startsection:
            labelText = "起始课节"
        case .endsection:
            labelText = "结束课节"
        }
        nameLabel.text = labelText
    }
}

extension AddcourseCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch type! {
        case .place:
            formatCorrect = content.text != nil
        case .startweek:
            fallthrough
        case .endweek:
            formatCorrect = (1 ... 20).contains(Int(content.text ?? "") ?? 0)
        case .weekday:
            formatCorrect = (1 ... 7).contains(Int(content.text ?? "") ?? 0)
        case .startsection:
            fallthrough
        case .endsection:
            formatCorrect = (1 ... 12).contains(Int(content.text ?? "") ?? 0)
        }
    }
}
