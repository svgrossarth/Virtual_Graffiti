//
//  Database.swift
//  Login
//
//  Created by Stephen Ednave on 2/8/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import SceneKit

class Database {
    let degreeDecimalPlaces : Int = 3
    
    let db = Firestore.firestore()
    var colRef : CollectionReference!
    var docRef : DocumentReference!
    
    // retval: Local save success
    func saveDrawing(location : CLLocation, points : [Point]) -> Void {
        let latitude : CLLocationDegrees = location.coordinate.latitude
        let longitude : CLLocationDegrees = location.coordinate.longitude
        // Tiles divided into 0.01 of a degree, or around 0.06 x 0.06 miles at the equator
        // Longitude gets bigger at the equator and smaller at poles
        let tile = doubleToString(number:latitude, numberOfDecimalPlaces:degreeDecimalPlaces) + ", " + doubleToString(number:longitude, numberOfDecimalPlaces:degreeDecimalPlaces)
        let collectionPath = "tiles/\(tile)/points"
        let docPath = collectionPath + "\(latitude), \(longitude)"
        docRef = db.document(docPath)
        
        // TODO: Save drawing!
        var dataToSave: [String: Any] = [:]
        for point in points {
            let position = "\(point.x), \(point.y), \(point.z)"
            dataToSave[position] = point
        }
        
        docRef.setData(dataToSave) { (error) in
            if let error = error {
                print("Error saving drawing: \(error.localizedDescription)")
            }
            else {
                print("Data has been saved at \(docPath)")
            }
        }
    }
    
    
    func retrieveDrawing(location: CLLocation, drawFunction: @escaping (_ points : [Point]) -> Void) {
        _drawPoints3x3(location: location, drawFunction: drawFunction)
    }
    
    
    func _drawPoints3x3(location: CLLocation, drawFunction: @escaping (_ points : [Point]) -> Void) {
        let tile : CLLocation = location
        for lat in [-1, 0, 1] {
            for long in [-1, 0, 1] {
                let newCoordinate = CLLocationCoordinate2DMake(tile.coordinate.latitude + Double(lat * 10^(-degreeDecimalPlaces)), tile.coordinate.longitude + Double(long * 10^(-degreeDecimalPlaces)))
                let currentTile = CLLocation(coordinate: newCoordinate, altitude: tile.altitude, horizontalAccuracy: tile.horizontalAccuracy, verticalAccuracy: tile.verticalAccuracy, course: tile.course, speed: tile.speed, timestamp: tile.timestamp)
                _drawPoints(location:currentTile, drawFunction: drawFunction)
            }
        }
    }
    
    
    func _drawPoints(location : CLLocation, drawFunction: @escaping (_ points : [Point]) -> Void) {
        // Get points
        let latitude : CLLocationDegrees = location.coordinate.latitude
        let longitude : CLLocationDegrees = location.coordinate.longitude
        // Tiles divided into 0.01 of a degree, or around 0.06 x 0.06 miles at the equator
        // Longitude gets bigger at the equator and smaller at poles
        let tile = doubleToString(number:latitude, numberOfDecimalPlaces:degreeDecimalPlaces) + ", " + doubleToString(number:longitude, numberOfDecimalPlaces:degreeDecimalPlaces)
        let collectionPath = "tiles/\(tile)/points"
        db.collection(collectionPath).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error with query snapshot: \(err.localizedDescription)")
                return
            } else {
                if let snapshot = querySnapshot {
                    var points : [Point] = []
                    for point in snapshot.documents {
                        let data = point.data()
                        if let x = data["x"] as? Float, let y = data["y"] as? Float, let z = data["z"] as? Float {//, let material = data["material"] as? SCNMaterial {
                            points.append(Point(x: x, y: y, z: z))//, material: material))
                        }
                    }
                    drawFunction(points)
                } else{
                    print("No snapshot in query snapshot")
                }
            }
        }
    }
}


func doubleToString(number:Double, numberOfDecimalPlaces:Int) -> String {
    return String(format:"%.*f", numberOfDecimalPlaces, number)
}
