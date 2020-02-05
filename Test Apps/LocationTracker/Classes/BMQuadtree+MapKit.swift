//
//  BMQuadtree+MapKit.swift
//  Bikemap
//
//  Created by Adam Eri on 18/07/2017.
//  Copyright © 2017 Bikemap GmbH. Apache License 2.0
//

import Foundation
import CoreLocation
import MapKit
import simd

extension BMQuad {
  /// Returns a region around the location with the specified offset in meters.
  ///
  /// - Parameter offset: Offset in meters.
  public init(location: CLLocation, offset: CLLocationDistance) {
    let region = MKCoordinateRegion.init(
      center: location.coordinate,
      latitudinalMeters: offset,
      longitudinalMeters: offset)

    let min = SIMD2<Float>(
      Float(location.coordinate.latitude - region.span.latitudeDelta),
      Float(location.coordinate.longitude - region.span.longitudeDelta)
    )

    let max = SIMD2<Float>(
      Float(location.coordinate.latitude + region.span.latitudeDelta),
      Float(location.coordinate.longitude + region.span.longitudeDelta)
    )

    self.init(quadMin: min, quadMax: max)
  }
}

extension MKOverlay {

  /// Returns the minX and minY coordinates of the overlays quad.
  /// Used for settung up the quadtree of the map objects.
  public var quadMin: SIMD2<Float> {
    let region = MKCoordinateRegion.init(self.boundingMapRect)

    let centerX = region.center.latitude
    let centerY = region.center.longitude
    let spanX = region.span.latitudeDelta
    let spanY = region.span.longitudeDelta

    return SIMD2<Float>(
      Float(centerX - spanX),
      Float(centerY - spanY))
  }

  /// Returns the maxX and maxY coordinates of the overlays quad.
  /// Used for settung up the quadtree of the map objects.
  public var quadMax: SIMD2<Float> {
    let region = MKCoordinateRegion.init(self.boundingMapRect)

    let centerX = region.center.latitude
    let centerY = region.center.longitude
    let spanX = region.span.latitudeDelta
    let spanY = region.span.longitudeDelta

    return SIMD2<Float>(
      Float(centerX + spanX),
      Float(centerY + spanY))
  }

  /// Returns the bounding quad of the overlay.
  /// Used for settung up the quadtree of the map objects.
  public var boundingQuad: BMQuad {
    return BMQuad(quadMin: self.quadMin, quadMax: self.quadMax)
  }
}

extension CLLocationCoordinate2D {
  public var vector: vector_float2 {
    return SIMD2<Float>(
      Float(self.latitude),
      Float(self.longitude))
  }
}

extension CLLocation {
  public var vector: vector_float2 {
    return SIMD2<Float>(
      Float(self.coordinate.latitude),
      Float(self.coordinate.longitude))
  }
}

@available(OSX 10.12, *)
extension BMQuadtree {

  // MARK: - Debug

  public var debugOverlay: [MKPolygon] {
    let minx = CLLocationDegrees(self.quad.quadMin.x)
    let miny = CLLocationDegrees(self.quad.quadMin.y)
    let maxx = CLLocationDegrees(self.quad.quadMax.x)
    let maxy = CLLocationDegrees(self.quad.quadMax.y)
    let topLeft = CLLocationCoordinate2D(latitude: minx, longitude: maxy)
    let bottomLeft = CLLocationCoordinate2D(latitude: minx, longitude: miny)
    let topRight = CLLocationCoordinate2D(latitude: maxx, longitude: maxy)
    let bottomRight = CLLocationCoordinate2D(latitude: maxx, longitude: miny)
    let coords = [topLeft, bottomLeft, bottomRight, topRight]
    let treePolygon = MKPolygon(coordinates: coords, count: coords.count)
    var polygons: [MKPolygon] = [treePolygon]

    if self.hasQuads == true {
      polygons.append(contentsOf: self.northWest!.debugOverlay)
      polygons.append(contentsOf: self.northEast!.debugOverlay)
      polygons.append(contentsOf: self.southWest!.debugOverlay)
      polygons.append(contentsOf: self.northEast!.debugOverlay)
    }

    return polygons
  }
}
