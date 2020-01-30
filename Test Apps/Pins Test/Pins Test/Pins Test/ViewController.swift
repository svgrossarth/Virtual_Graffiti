import ARKit
import CoreLocation

class ViewController: UIViewController {
    struct ARPin {
        let name: String
        let location: CLLocation
        
        init(lat: CLLocationDegrees, lon: CLLocationDegrees, alt: CLLocationDistance, name: String) {
            location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), altitude: alt, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: Date())
            self.name = name
        }
    }
    
    private let arSKView = ARSKView()
    private let locationManager = CLLocationManager()
    /// The center of the AR World. This will be updated frequently to remain within ~worldRecenteringThreshold meters from the user
    private var worldCenter: CLLocation?
    /// The furthest away an anchor can be placed, in meters. If an anchor is more than 100 meters away, it won't be visible
    private let furthestAnchorDistance: Float = 75
    /// The distance, in meters, the device can travel away from the last world origin before a new world origin is calculated. `worldRecenteringThreshold` + `furthestAnchorDistance` should be less than 100
    private let worldRecenteringThreshold: Double = 10.0
    /// ARAnchor.identifier -> ARPin mapping
    private var pins: [UUID: ARPin] = [:]
    private var anchors: [ARAnchor] = []
    
    /// The list of landmark locations to show
    let locations: [ARPin] = [ARPin(lat: 38.537164518, lon: -121.742830362, alt: 52, name: "Shields Library")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        arSKView.delegate = self
        let scene = SKScene(size: view.bounds.size)
        arSKView.presentScene(scene)
        view.addSubview(arSKView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.requestWhenInUseAuthorization()
        
        AVCaptureDevice.requestAccess(for: .video) { [weak self] (granted) in
            if !granted {
                // AR won't work
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        arSKView.frame = view.bounds
    }
    
    private func updateWorldCenter(_ location: CLLocation) {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            return
        }
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        arSKView.session.run(configuration, options: [.resetTracking])
        worldCenter = location
    }
    
    private func placeLandmarks() {
        guard let center = worldCenter else {
            return
        }
        for landmark in locations {
            let anchorPoint = makeARAnchor(from: center, to: landmark.location)
            arSKView.session.add(anchor: anchorPoint)
            pins[anchorPoint.identifier] = landmark
            anchors.append(anchorPoint)
        }
    }
    
    /// Create the matrix that transforms `location` to `landmark`. If speed is a problem, these calculations can be done on a background thread.
    private func makeARAnchor(from location: CLLocation, to landmark: CLLocation) -> ARAnchor {
        // Calculate the displacement
        let distance = location.distance(from: landmark)
        let distanceTransform = simd_float4x4.translatingIdentity(x: 0, y: 0, z: -min(Float(distance), furthestAnchorDistance))
        // Calculate the horizontal rotation
        let rotation = Matrix.angle(from: location, to: landmark)
        // Calculate the vertical tilt
        let tilt = Matrix.angleOffHorizon(from: location, to: landmark)
        // Apply the transformations
        let tiltedTransformation = Matrix.rotateVertically(matrix: distanceTransform, around: tilt)
        let completedTransformation = Matrix.rotateHorizontally(matrix: tiltedTransformation, around: -rotation)
        return ARAnchor(transform: completedTransformation)
    }
    
    private func removeAllLandmarks() {
        anchors.forEach({
            arSKView.node(for: $0)?.removeFromParent()
            arSKView.session.remove(anchor: $0)
        })
        anchors = []
        pins = [:]
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            if worldCenter == nil || abs(worldCenter!.distance(from: location)) > worldRecenteringThreshold {
                removeAllLandmarks()
                updateWorldCenter(location)
                placeLandmarks()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            // AR won't work
            navigationController?.popViewController(animated: true)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            // AR won't work
            navigationController?.popViewController(animated: true)
        }
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
}

extension ViewController: ARSKViewDelegate {
    func view(_ view: ARSKView, didAdd node: SKNode, for anchor: ARAnchor) {
        guard let pin = pins[anchor.identifier] else {
            return
        }
        // Create and configure a label. Alternatively, this could be a custom view
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 275))
        label.text = pin.name
        guard let image = label.toImage() else {
            return
        }
        
        let labelNode = SKSpriteNode(texture: SKTexture(image: image))
        labelNode.name = anchor.identifier.uuidString
        node.addChild(labelNode)
    }
}
