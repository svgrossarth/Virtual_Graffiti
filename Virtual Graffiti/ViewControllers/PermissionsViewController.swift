//
//  PermissionsViewController.swift
//  Virtual Graffiti
//
//  Created by Stephen Ednave on 5/13/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//

import UIKit
import Foundation
import Combine
import SwiftUI // Uses SwiftUI because Stephen wanted to practice it lol
import CoreLocation
import AVFoundation


enum PermissionStatus {
    case cameraAuthorized
    case denied
    case notDetermined
}


struct PermissionsMotherView: View {
    @ObservedObject var viewRouter: ViewRouter
    
    var body: some View {
        VStack {
            if viewRouter.initialized == false {
                // Blank, should just display a splash screen
            }
            else {
                if viewRouter.permissionStatus == .denied {
                    CameraDeniedView(viewRouter: viewRouter)
                }
                else {
                    if viewRouter.permissionStatus == .cameraAuthorized {
                        RequestingLocationView(viewRouter: viewRouter)
                    }
                    else {
                        RequestingCameraView(viewRouter: viewRouter)
                    }
                }
            }
        }
    }
}

struct CameraDeniedView: View {
    @ObservedObject var viewRouter: ViewRouter
    
    var body: some View {
        VStack() {
            Text("Camera permissions were denied")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(64)
                .lineLimit(nil)
            Spacer()
            Text("To enable the camera, go to Settings > Virtual Graffiti and enable 'Camera'")
                .multilineTextAlignment(.center)
                .padding(8)
                .lineLimit(nil)
            Spacer()
            HStack {
                Spacer()
                Button(action: viewRouter.deniedButtonPressed) {
                    Text("Next")
                        .padding(64)
                }
            }
        }
    }
}

struct RequestingCameraView: View {
    @ObservedObject var viewRouter: ViewRouter
    
    var body: some View {
        VStack() {
            Text("Virtual Graffiti is requesting permission to use the camera.")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(64)
                .lineLimit(nil)
            Spacer()
            Text("Drawing is done in augmented reality. To use our app, please enable the camera.")
                .multilineTextAlignment(.center)
                .padding(8)
                .lineLimit(nil)
            Spacer()
            HStack {
                Spacer()
                Button(action: viewRouter.cameraButtonPressed) {
                    Text("Next")
                        .padding(64)
                }
            }
        }
    }
}

struct RequestingLocationView: View {
    @ObservedObject var viewRouter: ViewRouter
    
    var body: some View {
        VStack() {
            Text("Virtual Graffiti is requesting permission to use Location Services.")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(64)
                .lineLimit(nil)
            Spacer()
            Text("We use this to save and download drawings close to you. Saving and loading drawings will be disabled if you don't enable this.")
                .multilineTextAlignment(.center)
                .padding(8)
                .lineLimit(nil)
            Spacer()
            HStack {
                Spacer()
                Button(action: viewRouter.locationButtonPressed) {
                    Text("Next")
                        .padding(64)
                }
            }
        }
    }
}

class ViewRouter: ObservableObject, LocationManagerDelegate {
    let objectWillChange = PassthroughSubject<ViewRouter, Never>()
    var viewController : PermissionsViewController?
    var initialized : Bool = false
    var permissionStatus : PermissionStatus = .notDetermined {
        didSet { // didSet will get called when value is changed
            objectWillChange.send(self) // Refresh SwiftUI Views that observe this object
        }
    }
    
    
    func transitionOut() {
        viewController?.transitionOut()
    }
    
    func permissionsDenied() {
        permissionStatus = .denied
    }
    
    func deniedButtonPressed() {
        if checkCameraAuthorization() {
            permissionStatus = .notDetermined
        }
    }
    
    func cameraButtonPressed() {
        if checkCameraAuthorization() == true {
            cameraAuthorized()
            return
        }
        
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { success in
            if success {
                self.cameraAuthorized()
            }
            else {
                self.permissionsDenied()
            }
        })
    }
    
    func cameraAuthorized() {
        if checkLocationDetermined() {
            transitionOut()
        }
        else {
            permissionStatus = .cameraAuthorized
        }
    }
    
    func locationButtonPressed() -> Void {
        if checkLocationDetermined() == true {
            transitionOut()
        }
        else {
            sceneLocationManager.locationManager.requestAuthorization()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ locationManager: LocationManager, status: CLAuthorizationStatus) {
        if status != .notDetermined {
            transitionOut()
        }
    }
    
    
    func checkCameraAuthorization() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    func checkLocationAuthorization() -> Bool {
        let locationAuthorization = CLLocationManager.authorizationStatus()
        return locationAuthorization == .authorizedAlways || locationAuthorization == .authorizedWhenInUse
    }
    
    func checkCameraDetermined() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) != .notDetermined
    }
    
    func checkLocationDetermined() -> Bool {
        return CLLocationManager.authorizationStatus() != .notDetermined
    }
}


class PermissionsViewController: UIHostingController<PermissionsMotherView> {
    let viewRouter = ViewRouter()
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: PermissionsMotherView(viewRouter: viewRouter))
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        viewRouter.viewController = self
        sceneLocationManager.locationManager.delegate = viewRouter
        
        if viewRouter.checkCameraDetermined() {
            if viewRouter.checkCameraAuthorization() {
                if viewRouter.checkLocationDetermined() {
                    transitionOut()
                    return
                }
                viewRouter.cameraAuthorized()
            }
            else {
                viewRouter.permissionsDenied()
            }
        }
        
        viewRouter.initialized = true
    }
    
    
    func transitionOut() {
        sceneLocationManager.locationManager.delegate = sceneLocationManager
        
        DispatchQueue.main.async {
            // Has to be asynchronous or it crashes
            // Why? Who knows
            if self.viewRouter.checkLocationAuthorization() {
                self.performSegue(withIdentifier: "login", sender: self)
            }
            else {
                self.performSegue(withIdentifier: "drawing", sender: self)
            }
        }

    }
}


#if DEBUG
struct PermissionsMotherView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsMotherView(viewRouter: ViewRouter())
    }
}
#endif
