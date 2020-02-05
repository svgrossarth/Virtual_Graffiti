//
//  BMQuad.swift
//  BMQuadtree
//
//  Created by Adam Eri on 04.12.18.
//

import Foundation
import simd

/// Representation of an axis aligned quad via its min corner (lower-left)
/// and max corner (upper-right)
public struct BMQuad {

  /// The lower-left coordinate of the element
  public var quadMin: vector_float2

  /// The upper-right coordinate of the element
  public var quadMax: vector_float2
}

extension BMQuad {

  /// Checks if the point specified is within this quad.
  ///
  /// - Parameter point: the point to query
  /// - Returns: Returns true if the point specified is within this quad.
  public func contains(_ point: vector_float2) -> Bool {

    // Above lower left corner
    let gtMin = (point.x >= self.quadMin.x && point.y >= self.quadMin.y)

    // Below upper right coner
    let leMax = (point.x <= self.quadMax.x && point.y <= self.quadMax.y)

    // If both is true, the point is inside the quad.
    return (gtMin && leMax)
  }

  /// Checks if the specified quad intersects with self.
  ///
  /// - Parameter quad: the quad to query
  /// - Returns: Returns true if the quad intersects
  public func intersects(_ quad: BMQuad) -> Bool {

    if self.quadMin.x > quad.quadMax.x ||
      self.quadMin.y > quad.quadMax.y {
      return false
    }

    if self.quadMax.x < quad.quadMin.x ||
      self.quadMax.y < quad.quadMin.y {
      return false
    }

    return true
  }
}
