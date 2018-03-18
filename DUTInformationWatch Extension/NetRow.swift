//
//  NetRow.swift
//  DUTInformationWatch Extension
//
//  Created by shino on 08/03/2018.
//  Copyright © 2018 shino. All rights reserved.
//

import WatchKit

class NetRow: NSObject {
    @IBOutlet var flowLable: WKInterfaceLabel!
    @IBOutlet var costLabel: WKInterfaceLabel!
    
    func prepare(_ net: (cost: String, flow: String)) {
        costLabel.setText(net.cost)
        flowLable.setText(net.flow)
    }
}
