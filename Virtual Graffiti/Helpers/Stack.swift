//
//  stack.swift
//  Login
//
//  Created by Spencer Grossarth on 4/15/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//
//  https://www.raywenderlich.com/800-swift-algorithm-club-swift-stack-data-structure

import Foundation
import SceneKit
struct Stack<Element> {
    fileprivate var array: [[String : SCNNode]] = []
    
    mutating func push(_ element: [String : SCNNode]) {
        array.append(element)
    }
    
    mutating func pop() -> [String : SCNNode]? {
        return array.popLast()
    }
    
    func peek() -> [String : SCNNode]? {
        return array.last
    }
    
    func count() -> Int {
        return array.count
    }
    
    mutating func searchAndRemoveDup(node : SCNNode){
        if array.count > 0 {
            guard let newNodeName = node.name else {
                print("Get get newNodeName in stack")
                return
            }
            var count = array.count
            for var i in 0..<count {
                guard let elementNode = array[i].first?.value else {
                    print("can't get element node in stack")
                    return
                }
                guard let elementName = elementNode.name else {
                    print("can't get element name in stack")
                    return
                }
                if elementName == newNodeName {
                    array.remove(at: i)
                    i -= 1
                    count -= 1
                }
            }
        }
    }
}
