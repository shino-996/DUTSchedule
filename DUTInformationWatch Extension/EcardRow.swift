//
//  EcardRow.swift
//  DUTInformationWatch Extension
//
//  Created by shino on 08/03/2018.
//  Copyright © 2018 shino. All rights reserved.
//

import WatchKit

class EcardRow: NSObject {
    @IBOutlet var ecardLabel: WKInterfaceLabel!
    
    func prepare(ecard: String) {
        ecardLabel.setText(ecard)
    }
}
