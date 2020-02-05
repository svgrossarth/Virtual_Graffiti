import XCTest
@testable import BMQuadtree

import XCTest
import MapKit
import GameplayKit

final class BMQuadtreeTests: XCTestCase {

  private var duplicateTree: BMQuadtree<AnyObject>?
  private var largeTree: BMQuadtree<AnyObject>?
  private var largeCoordinateSet: [CLLocationCoordinate2D] = []

  /// Testing a data set with many duplicates.
  /// The problem with duplicates is that the tree tries to split the quad
  /// infitely for saving the same point.
  func testDuplicates() {
    for item in self.coordinatesArrayWithDuplicates {
      let latitude = item[0]
      let longitude = item[1]
      let location = CLLocation(latitude: latitude, longitude: longitude)
      self.duplicateTree?.add(location, at: location.vector)
    }
  }

  /// Performance measurement with a large data set of 100.000 items.
  func testLargeTreeSetup() {
    let largeOverlay = MKPolyline(
      coordinates: self.largeCoordinateSet,
      count: self.largeCoordinateSet.count)

    self.measure {
      let largeTree = BMQuadtree<AnyObject>(
        boundingQuad: largeOverlay.boundingQuad,
        minimumCellSize: 3)

      for item in self.largeCoordinateSet {
        let location = CLLocation(
          latitude: item.latitude,
          longitude: item.longitude)
        largeTree.add(location, at: location.vector)
      }
    }
  }

  /// Performance measurement for finding the nearest element to coordinates 0,0
  /// in a large data set of 100.000 items.
  func testLargeTreeNearestSearch() {
    self.measure {
      let nearest = self.largeTree?.element(nearestTo: float2(0, 0))
      print(nearest ?? "Nearest element not found")
    }
  }

  override func setUp() {
    super.setUp()

    // Duplicate test setup
    let coordinates: [CLLocationCoordinate2D] = self
      .coordinatesArrayWithDuplicates.map {
        return CLLocationCoordinate2D(latitude: $0[0], longitude: $0[1])
    }

    let overlay = MKPolyline(
      coordinates: coordinates,
      count: coordinates.count)

    self.duplicateTree = BMQuadtree(
      boundingQuad: overlay.boundingQuad,
      minimumCellSize: 3)

    // Large test setup
    let rand = GKMersenneTwisterRandomSource()
    let distribution = GKRandomDistribution(
      randomSource: rand,
      lowestValue: -100,
      highestValue: 100)

    for _ in 0...100000 {
      let latitude: CLLocationDegrees =
        CLLocationDegrees(distribution.nextUniform())
      let longitude: CLLocationDegrees =
        CLLocationDegrees(distribution.nextUniform())
      let coordinate = CLLocationCoordinate2D(
        latitude: latitude,
        longitude: longitude)
      self.largeCoordinateSet.append(coordinate)
    }

    let largeOverlay = MKPolyline(
      coordinates: self.largeCoordinateSet,
      count: self.largeCoordinateSet.count)

    self.largeTree = BMQuadtree(
      boundingQuad: largeOverlay.boundingQuad,
      minimumCellSize: 3)

    for item in self.largeCoordinateSet {
      let location: CLLocation = CLLocation(
        latitude: item.latitude,
        longitude: item.longitude)
      self.largeTree?.add(location, at: location.vector)
    }
  }

  override func tearDown() {
    super.tearDown()
  }

  private let coordinatesArrayWithDuplicates = [
    [37.33758, -122.03492],
    [37.33758, -122.03492],
    [37.33757, -122.03471],
    [37.33757, -122.03471],
    [37.33748, -122.03515],
    [37.33748, -122.03515],
    [37.33749, -122.03241],
    [37.33749, -122.0335307566392],
    [37.33749, -122.03241],
    [37.33762, -122.02892],
    [37.33753183696947, -122.0300245464757],
    [37.33762, -122.02892],
    [37.33765, -122.02331],
    [37.33765, -122.0244329460325],
    [37.33765, -122.02331],
    [37.33024, -122.02322],
    [37.33112838140178, -122.0232286250621],
    [37.33024, -122.02322],
    [37.32982, -122.01973],
    [37.33007149391726, -122.020795285888],
    [37.32982, -122.01973],
    [37.32302, -122.01963],
    [37.32389881834109, -122.019636996813],
    [37.32302, -122.01963],
    [37.32284, -122.01962],
    [37.32284, -122.01962],
    [37.32287, -122.01431],
    [37.32286, -122.0154285535921],
    [37.32287, -122.01431],
    [37.31992, -122.01413],
    [37.32079750297464, -122.0142543750826],
    [37.31992, -122.01413],
    [37.31966, -122.01402],
    [37.31966, -122.01402],
    [37.31774, -122.01325],
    [37.25207, -121.96434],
    [37.25207, -121.96434],
    [37.25199, -121.96441],
    [37.25199, -121.96441],
    [37.25199, -121.96441],
    [37.25199, -121.96441],
    [37.2519, -121.96448],
    [37.2519, -121.96448],
    [37.2519, -121.96448],
    [37.2519, -121.96448],
    [37.25181, -121.96455],
    [37.25181, -121.96455],
    [37.25181, -121.96455],
    [37.25181, -121.96455],
    [37.25172, -121.96463],
    [37.25172, -121.96463],
    [37.25172, -121.96462],
    [37.25172, -121.96462],
    [37.25172, -121.96462],
    [37.25172, -121.96462],
    [37.25172, -121.96463],
    [37.25172, -121.96463],
    [37.2516, -121.96472],
    [37.2516, -121.96472],
    [37.2516, -121.96472],
    [37.2516, -121.96472],
    [37.25151, -121.96479],
    [37.25151, -121.96479],
    [37.25151, -121.96479],
    [37.25151, -121.96479]
  ]
}

