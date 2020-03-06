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
    let degreeDecimalPlaces : Int = 4
    
    let db = Firestore.firestore()
    var colRef : CollectionReference!
    var docRef : DocumentReference!
    let DICT_KEY = "node"
    
    // retval: Local save success
    func saveDrawing(location : CLLocation, userRootNode : SecondTierRoot) -> Void {
        let latitude : CLLocationDegrees = location.coordinate.latitude
        let longitude : CLLocationDegrees = location.coordinate.longitude
        // Tiles divided into 0.01 of a degree, or around 0.06 x 0.06 miles at the equator
        // Longitude gets bigger at the equator and smaller at poles
        let tile = doubleToString(number:latitude, numberOfDecimalPlaces:degreeDecimalPlaces) + ", " + doubleToString(number:longitude, numberOfDecimalPlaces:degreeDecimalPlaces)
        let collectionPath = "tiles/\(tile)/nodes"
        guard let nodeName = userRootNode.name else {
            print("Node doesn't have name")
            return
        }
        let docPath = collectionPath + "/" + nodeName
        docRef = db.document(docPath)
        
        // TODO: Save drawing!
        var dataToSave: [String: Any] = [:]
        do{
            let nodeData = try NSKeyedArchiver.archivedData(withRootObject: userRootNode, requiringSecureCoding: false)
            
            
            dataToSave[DICT_KEY] = nodeData
            docRef.setData(dataToSave) { (error) in
                if let error = error {
                    print("Error saving drawing: \(error.localizedDescription)")
                }
                else {
                    print("Data has been saved at \(docPath)")
                }
            }
        } catch{
            print("Can't convert node to data")
            
        }
    }
    
    
    func retrieveDrawing(location: CLLocation, drawFunction: @escaping (_ nodes : [SecondTierRoot]) -> Void) {
        _drawPoints3x3(location: location, drawFunction: drawFunction)
    }
    
    
    func _drawPoints3x3(location: CLLocation, drawFunction: @escaping (_ nodes : [SecondTierRoot]) -> Void) {
        let tile : CLLocation = location
        for lat in [-1, 0, 1] {
            for long in [-1, 0, 1] {
                let newCoordinate = CLLocationCoordinate2DMake(tile.coordinate.latitude + Double(lat * 10^(-degreeDecimalPlaces)), tile.coordinate.longitude + Double(long * 10^(-degreeDecimalPlaces)))
                let currentTile = CLLocation(coordinate: newCoordinate, altitude: tile.altitude, horizontalAccuracy: tile.horizontalAccuracy, verticalAccuracy: tile.verticalAccuracy, course: tile.course, speed: tile.speed, timestamp: tile.timestamp)
                _drawPoints(location:currentTile, drawFunction: drawFunction)
            }
        }
    }
    
    
    func _drawPoints(location : CLLocation, drawFunction: @escaping (_ nodes : [SecondTierRoot]) -> Void) {
        // Get points
        let latitude : CLLocationDegrees = location.coordinate.latitude
        let longitude : CLLocationDegrees = location.coordinate.longitude
        // Tiles divided into 0.01 of a degree, or around 0.06 x 0.06 miles at the equator
        // Longitude gets bigger at the equator and smaller at poles
        let tile = doubleToString(number:latitude, numberOfDecimalPlaces:degreeDecimalPlaces) + ", " + doubleToString(number:longitude, numberOfDecimalPlaces:degreeDecimalPlaces)
        let collectionPath = "tiles/\(tile)/nodes"
        db.collection(collectionPath).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error with query snapshot: \(err.localizedDescription)")
                return
            } else {
                if let snapshot = querySnapshot {
                    var nodes : [SecondTierRoot] = []
                    for response in snapshot.documents {
                        do {
                            let dictionary = response.data()
                            guard let nodeData = dictionary[self.DICT_KEY] as? Data else{
                                print("can't convert to data")
                                return
                            }
                            let newData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(nodeData)
                            let newNode = newData as! SecondTierRoot
                            nodes.append(newNode)
                        } catch {
                            print("Could not pull down node")
                        }
                        
                    }
                    drawFunction(nodes)
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
