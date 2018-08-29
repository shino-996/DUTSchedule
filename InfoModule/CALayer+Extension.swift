//
//  CALayer+Extension.swift
//  DUTInfomation
//
//  Created by shino on 2018/8/29.
//  Copyright © 2018年 shino. All rights reserved.
//

import UIKit

extension CALayer {
    var borderColorFromUIColor: UIColor? {
        get {
            if let color = borderColor {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }
        
        set {
            if let color = newValue {
                borderColor = color.cgColor
            } else {
                borderColor = nil
            }
        }
    }
}
