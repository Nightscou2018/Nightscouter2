//
//  Encodable.swift
//  SwiftGoal
//
//  Created by Martin Richter on 01/01/16.
//  Copyright © 2016 Martin Richter. All rights reserved.
//
import Foundation

public protocol Encodable {
    func encode() -> [String: AnyObject]
}

public protocol Decodable {
    static func decode(dict: [String: AnyObject]) -> Self?
}