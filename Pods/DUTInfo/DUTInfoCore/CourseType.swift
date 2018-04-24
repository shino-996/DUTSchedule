//
//  CourseType.swift
//  DUTInfoDemo
//
//  Created by shino on 26/03/2018.
//  Copyright © 2018 shino. All rights reserved.
//

import Foundation

public struct Course: Encodable {
    public var name: String
    public var teacher: String
    public var time: [Time]?
}

public struct Time: Encodable {
    public var place: String
    public var startsection: Int
    public var endsection: Int
    public var week: Int
    public var teachweek: [Int]
}
