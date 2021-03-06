//
//  TestViewDataSource.swift
//  DUTInfomation
//
//  Created by shino on 18/12/2017.
//  Copyright © 2017 shino. All rights reserved.
//

import UIKit

class TestViewDataSource: NSObject, UITableViewDataSource {
    var tests: [TestData]
    
    init(tests: [TestData]) {
        self.tests = tests
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tests.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestCell", for: indexPath) as! TestCell
        cell.prepare(tests: tests, indexPath: indexPath)
        return cell
    }
}
