//
//  BMQuadtreeNode.swift
//  BMQuadtree
//
//  Created by Adam Eri on 04.12.18.
//

import Foundation

/**
 A helper class for managing the objects you organize in a quadtree.

 You don’t create instances of this class directly; instead, a BMQuadtree
 object provides you with a BMQuadtreeNode instance when you add an element
 to a tree. Keep references to the corresponding nodes so you can use them
 for better performance when accessing or removing elements.
 */
public class BMQuadtreeNode <T: AnyObject> {

  /// The weakly references tree within this BMQuadtreeNode
  weak public var tree: BMQuadtree<T>?

  /// The axis-aligned bounding rectangle represented by the node.
  public var quad: BMQuad

  /// Initialises and returns a BMQuadtreeNode.
  ///
  /// - Parameter tree: The tree stored in this node.
  public init(tree: BMQuadtree<T>) {
    self.tree = tree
    self.quad = tree.quad
  }
}
