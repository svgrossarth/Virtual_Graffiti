//
//  stack.swift
//  Login
//
//  Created by Spencer Grossarth on 4/15/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//
//  https://www.raywenderlich.com/800-swift-algorithm-club-swift-stack-data-structure

import Foundation
struct Stack<Element> {
  fileprivate var array: [Element] = []
  
  mutating func push(_ element: Element) {
    array.append(element)
  }
  
  mutating func pop() -> Element? {
    return array.popLast()
  }
  
  func peek() -> Element? {
    return array.last
  }
}
