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


enum Permissions {
    case LOCATION
    case CAMERA
    case DECLINED
}


struct DeclineButton: View {
    @ObservedObject var viewRouter: ViewRouter
    
    var body: some View {
        Button(action: {
            self.viewRouter.declinePermission()
        })  {
            Text("Decline")
                .padding(64)
        }
    }
}


struct PermissionsMotherView: View {
    @ObservedObject var viewRouter: ViewRouter
    
    var body: some View {
        VStack {
            Text("Virtual Graffiti is requesting the following permissions.")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(64)
            Spacer()
            if viewRouter.permission == Permissions.LOCATION {
                PermissionsLocationView(viewRouter: viewRouter)
            }
            else if viewRouter.permission == Permissions.CAMERA {
                PermissionsCameraView(viewRouter: viewRouter)
            }
            else {
                PermissionsDeclinedView(viewRouter: viewRouter)
            }
        }
    }
}


struct PermissionsLocationView: View {
    @ObservedObject var viewRouter: ViewRouter
    
    var body: some View {
        VStack {
            Text("Access to your phone's location. We use this to upload and download drawings close to you.")
                .multilineTextAlignment(.center)
                .padding(64)
            
            Spacer()
            
            HStack {
                DeclineButton(viewRouter: viewRouter)
                
                Spacer()
                
                Button(action: {
                    if CLLocationManager.authorizationStatus() == .authorizedAlways ||
                        CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                        self.viewRouter.acceptPermission(permission: Permissions.LOCATION)
                    }
                    else {
                        sceneLocationManager.locationManager.requestAuthorization()
                    }
                })  {
                    Text("Accept")
                        .padding(64)
                }
            }
        }
    }
}


struct PermissionsCameraView: View {
    @ObservedObject var viewRouter: ViewRouter
    
    var body: some View {
        VStack {
            Text("Access to your phone's camera. We use this to display drawings and allow you to draw in Augmented Reality.")
                .multilineTextAlignment(.center)
                .padding(64)
            
            Spacer()
            
            HStack {
                DeclineButton(viewRouter: viewRouter)
                
                Spacer()
                
                Button(action: {
                    if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                        self.viewRouter.acceptPermission(permission: Permissions.CAMERA)
                    }
                    else {
                        AVCaptureDevice.requestAccess(for: .video, completionHandler: { success in
                            if success {
                                self.viewRouter.acceptPermission(permission: Permissions.CAMERA)
                            }
                        })
                    }
                })  {
                    Text("Accept")
                        .padding(64)
                }
            }
        }
    }
}


struct PermissionsDeclinedView: View {
    @ObservedObject var viewRouter: ViewRouter
    
    var body: some View {
        VStack {
            Text("Please accept the permissions before using this app.")
                .multilineTextAlignment(.center)
                .padding(64)
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    self.viewRouter.acceptPermission(permission: Permissions.DECLINED)
                })  {
                    Text("Accept")
                        .padding(64)
                }
            }
        }
    }
}



class ViewRouter: ObservableObject {
    let objectWillChange = PassthroughSubject<ViewRouter, Never>()
    var viewController : PermissionsViewController?
    
    var permission = Permissions.LOCATION {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    var currentPermissionRequest : Permissions = Permissions.LOCATION
    
    
    func acceptPermission(permission: Permissions) {
        switch permission {
        case Permissions.LOCATION :
            self.permission = Permissions.CAMERA
            if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                viewController?.transitionToViewController()
                return
            }
        case Permissions.CAMERA:
            viewController?.transitionToViewController()
            return
        default: // Declined, move out of declined
            self.permission = currentPermissionRequest
            return
        }
        
        currentPermissionRequest = self.permission
    }
    
    func declinePermission() {
        permission = Permissions.DECLINED
    }
}


class PermissionsViewController: UIHostingController<PermissionsMotherView> {
    let viewRouter = ViewRouter()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: PermissionsMotherView(viewRouter: viewRouter))
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sceneLocationManager.locationManager.requestAuthorization()
        if CLLocationManager.authorizationStatus() == .authorizedAlways ||
             CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
             
            // This block is in because otherwise the device can't fetch authorization status this early on in the program
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { success in
                if success {
                    self.transitionToViewController()
                }
            })
            if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                self.transitionToViewController()
            } else {
                viewRouter.acceptPermission(permission: Permissions.LOCATION)
            }
         }
        
        viewRouter.viewController = self
    }
    
    func transitionToViewController() {
        DispatchQueue.main.async {
            let viewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.viewController) as? ViewController
            self.view.window?.rootViewController = viewController
            self.view.window?.makeKeyAndVisible()
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
