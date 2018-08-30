//
//  AddCourseViewController.swift
//  DUTInfomation
//
//  Created by shino on 2018/8/29.
//  Copyright © 2018年 shino. All rights reserved.
//

import UIKit

class AddCourseViewController: UITableViewController {
    @IBOutlet weak var nameContent: UITextField!
    @IBOutlet weak var teacherContent: UITextField!
    
    var numOfTime = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(UINib(nibName: "AddCourseCell", bundle: nil),
                           forCellReuseIdentifier: "AddCourseCell")
        tableView.register(UINib(nibName: "AddCourseHeaderCell", bundle: nil),
                           forCellReuseIdentifier: "AddCourseHeaderCell")
        
        NotificationCenter.default.addObserver(forName: "space.shino.post.deletecoursecell") { [unowned self] _ in
            if self.numOfTime == 4 {
                let indexPath = IndexPath(row: 0, section: self.tableView.numberOfSections - 1)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                self.tableView.cellForRow(at: indexPath)?.isHidden = false
            }
            self.numOfTime -= 1
            let indexPathArray = (0 ..< 7).map { IndexPath(row: $0, section: self.numOfTime + 1) }
            self.tableView.deleteRows(at: indexPathArray, with: .automatic)
        }
    }
    
    deinit {
        NotificationCenter.default.post(name: "space.shino.post.addcourse")
        NotificationCenter.default.removeObserver(self)
    }
}

// UITableViewDataSource 实现
extension AddCourseViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (1 ..< tableView.numberOfSections - 1).contains(section) {
            if section - 1 < numOfTime {
                return 6 + 1
            } else {
                return 0
            }
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (1 ..< tableView.numberOfSections - 1).contains(indexPath.section) {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddCourseHeaderCell") as! AddCourseHeaderCell
                if indexPath.section > 1 {
                    cell.deleteButton.isHidden = false
                } else {
                    cell.deleteButton.isHidden = true
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddCourseCell") as! AddcourseCell
                cell.prepare(indexPath)
                return cell
            }
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if (1 ..< tableView.numberOfSections - 1).contains(indexPath.section) {
            return super.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 0, section: 0))
        } else {
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (1 ..< tableView.numberOfSections - 1).contains(indexPath.section) {
            if indexPath.section - 1 < numOfTime {
                if indexPath.row == 0 {
                    return tableView.sectionHeaderHeight
                }
                let newIndexPath = IndexPath(row: 0, section: 0)
                return super.tableView(tableView, heightForRowAt: newIndexPath)
            } else {
                return super.tableView(tableView, heightForRowAt: indexPath)
            }
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}

// UITableViewDelegate 实现
extension AddCourseViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == tableView.numberOfSections - 1 else {
            return
        }
        numOfTime += 1
        let indexPathArray = (0 ..< 7).map { IndexPath(row: $0, section: numOfTime) }
        if numOfTime == 4 {
            let indexPath = IndexPath(row: 0, section: tableView.numberOfSections - 1)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            tableView.cellForRow(at: indexPath)?.isHidden = true
        }
        tableView.insertRows(at: indexPathArray, with: .automatic)
    }
}

// 保存 & 取消修改
extension AddCourseViewController {
    @IBAction func cancelAdd() {
        self.dismiss(animated: true)
    }
    
    @IBAction func saveAdd() {
        guard let data = courseInput() else {
            print("Add course input error!")
            return
        }
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: "space.shino.post.addcourseresult",
                                            userInfo: ["course": data])
        }
    }
    
    func courseInput() -> Data? {
        guard let name = nameContent.text else {
            return nil
        }
        guard let teacher = teacherContent.text else {
            return nil
        }
        var timeArray: [JsonDataType.Course.time] = []
        for section in 1 ..< 1 + numOfTime {
            var contentArray: [String] = []
            for row in 0 ..< 6 {
                let indexPath = IndexPath(row: row, section: section)
                var courseCell: AddcourseCell
                if let cell = tableView.cellForRow(at: indexPath) {
                    courseCell = cell as! AddcourseCell
                } else {
                    tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    courseCell = tableView.cellForRow(at: indexPath)! as! AddcourseCell
                }
                if courseCell.formatCorrect == false {
                    return nil
                }
                contentArray.append(courseCell.content.text!)
            }
            let time = JsonDataType.Course.time(place: contentArray[0],
                                                startsection: Int(contentArray[4])!,
                                                endsection: Int(contentArray[5])!,
                                                startweek: Int(contentArray[1])!,
                                                endweek: Int(contentArray[2])!,
                                                weekday: Int(contentArray[3])!)
            timeArray.append(time)
        }
        let course = JsonDataType.Course(name: name, teacher: teacher, time: timeArray)
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(course)
            return data
        } catch (let error) {
            print(error)
            return nil
        }
    }
}
