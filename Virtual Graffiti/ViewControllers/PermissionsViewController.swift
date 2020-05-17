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
    case authorized
    case denied
    case notDetermined
}


struct PermissionsMotherView: View {
    @ObservedObject var viewRouter: ViewRouter
    
    var body: some View {
        VStack {
            if viewRouter.initialized == false {
                // Blank, don't display anything until fully initialized
            }
            else {
                if viewRouter.permissionStatus == .denied {
                    Text("Virtual Graffiti permissions were denied")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding(64)
                    
                    Spacer()
                    
                    Text("To enable permissions, go to Settings > Virtual Graffiti and enable 'Camera' and 'Location Services'")
                        .multilineTextAlignment(.center)
                        .padding(64)
                    
                    Spacer()
                }
                else {
                    Text("Virtual Graffiti is requesting the following permissions")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding(64)
                    
                    Spacer()
                    
                    Text("Camera: We use this to display drawings and allow you to draw in Augmented Reality.")
                        .padding(64)
                    Text("Location: We use this to upload and download drawings close to you.")
                        .padding(64)
                    
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: viewRouter.requestAuthorization)
                    {
                        Text("Next")
                            .padding(64)
                    }
                }
            }
        }
    }
}


class ViewRouter: ObservableObject, LocationManagerDelegate {
    let objectWillChange = PassthroughSubject<ViewRouter, Never>()
    var viewController : PermissionsViewController?
    var permissionStatus : PermissionStatus = .notDetermined {
        didSet {
            objectWillChange.send(self)
        }
    }
    var initialized : Bool = false
    
    
    func permissionsAccepted() {
        permissionStatus = .authorized
        viewController?.transitionOut()
    }
    
    func permissionsDenied() {
        permissionStatus = .denied
    }
    
    func checkPermissions() -> Bool {
        return checkCameraAuthorization() && checkLocationAuthorization()
    }
    
    func checkCameraAuthorization() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    func checkLocationAuthorization() -> Bool {
        let locationAuthorization = CLLocationManager.authorizationStatus()
        return (locationAuthorization == .authorizedAlways || locationAuthorization == .authorizedWhenInUse)
    }
    
    func checkAuthorizationDetermined() -> Bool {
        let determined = AVCaptureDevice.authorizationStatus(for: .video) != .notDetermined && CLLocationManager.authorizationStatus() != .notDetermined
        return determined
    }
    
    
    func requestAuthorization() -> Void {
        // If permissions already authorized, move on
        if checkPermissions() {
            permissionsAccepted()
            return
        }
        
        // Authorize location closure
        let authorizeLocation = {
            if self.checkLocationAuthorization() == true {
                self.permissionsAccepted()
            }
            else {
                sceneLocationManager.locationManager.requestAuthorization()
            }
        }
        
        // Authorize camera first
        if checkCameraAuthorization() == true {
            authorizeLocation()
        }
        else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { _ in
                authorizeLocation()
            })
        }
        
        
        if checkAuthorizationDetermined() && checkPermissions() == false {
            permissionsDenied()
        }
    }

    
    func locationManagerDidChangeAuthorization(_ locationManager: LocationManager, status: CLAuthorizationStatus) {
        if checkAuthorizationDetermined() {
            if checkPermissions() {
                permissionsAccepted()
            }
            else {
                permissionsDenied()
            }
        }
    }
}


class PermissionsViewController: UIHostingController<PermissionsMotherView> {
    let viewRouter = ViewRouter()
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: PermissionsMotherView(viewRouter: viewRouter))
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewRouter.viewController = self
        viewRouter.permissionStatus = .notDetermined
        sceneLocationManager.locationManager.delegate = viewRouter
        
        if viewRouter.checkAuthorizationDetermined() {
            if viewRouter.checkPermissions() {
                viewRouter.permissionsAccepted()
            }
            else {
                viewRouter.permissionsDenied()
                viewRouter.initialized = true
            }
        }
        else {
            viewRouter.initialized = true
        }
    }
    
    
    func transitionOut() {
        sceneLocationManager.locationManager.delegate = sceneLocationManager
        
        DispatchQueue.main.async {
            // Segue has to be asynchronous or it won't automatically transition if permissions are enabled.
            // Why? Who knows.
            self.performSegue(withIdentifier: "next", sender: self)
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
