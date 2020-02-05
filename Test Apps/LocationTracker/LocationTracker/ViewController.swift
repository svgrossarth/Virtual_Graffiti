//
//  ViewController.swift
//  LocationTracker
//
//  Created by User on 2/5/20.
//  Copyright © 2020 VirtualGraffiti. All rights reserved.
//

import UIKit
import GameplayKit // For GKQuad
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var xTextField: UITextField!
    @IBOutlet weak var yTextField: UITextField!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    let quadtree : BMQuadtree = BMQuadtree<CLLocation>(boundingQuad: BMQuad.init(quadMin: vector_float2(-180.0, -90.0), quadMax: vector_float2(180.0, 90.0)), minimumCellSize: 1.0)
    let checkedDegrees : Float = 1.0
    let testDatabase : Array = [CLLocation(latitude: 0.0, longitude: 0.0),
                              CLLocation(latitude: 1.0, longitude: 0.0),
                              CLLocation(latitude: 0.0, longitude: 1.0),
                              CLLocation(latitude: 0.5, longitude: 0.0),
                              CLLocation(latitude: 0.5, longitude: 0.5),
                              CLLocation(latitude: 2.0, longitude: 0.0),
                              CLLocation(latitude: 0.0, longitude: 2.0)]
    let locManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        xTextField.delegate = self
        yTextField.delegate = self
        
        for point in testDatabase {
            quadtree.add(point, at: SIMD2<Float>(Float(point.coordinate.latitude), Float(point.coordinate.longitude)))
        }
        
        locManager.requestWhenInUseAuthorization()
    }

    func updatePoints(min : vector_float2, max : vector_float2) {
        let points = quadtree.elements(in: BMQuad.init(quadMin: min, quadMax: max))
        pointsLabel.text = ""
        for point in points {
            pointsLabel.text! += "(\(point.coordinate.latitude), \(point.coordinate.longitude), \(point.altitude)), \n"
        }
    }
    
    
    @IBAction func updateLocationButtonTouchUpInside(_ sender: Any) {
        updateLocation()
    }
    
    func updateLocation() {
        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) {
            currentLocation = locManager.location
        }
    }
    
    @IBAction func saveLocationButtonTouchUpInside(_ sender: Any) {
        saveLocation()
        locationLabel.text = "Latitude: \(currentLocation.coordinate.latitude), Longitude: \(currentLocation.coordinate.longitude)"
    }
    
    func saveLocation() {
        updateLocation()
    }
}


extension ViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let xText = xTextField.text, let yText = yTextField.text {
            if let x = Float(xText), let y = Float(yText) {
                let location = vector_float2(x, y)
                let min = vector_float2(location.x - checkedDegrees, location.y - checkedDegrees)
                let max = vector_float2(location.x + checkedDegrees, location.y + checkedDegrees)
                updatePoints(min:min, max:max)
            }
        }
        return true
    }
}
