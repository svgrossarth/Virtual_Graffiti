//
//  ViewController.swift
//  Login
//
//  Created by Elvis Alvarado on 1/26/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//
import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import AuthenticationServices
import CryptoKit

class ViewController: UIViewController, GIDSignInDelegate, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var googleLoginButton: GIDSignInButton!
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        createAppleIDButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(Auth.auth().currentUser?.uid)
        if Auth.auth().currentUser?.uid != nil {
            transitionToHome(userUID: Auth.auth().currentUser?.uid ?? "")
        }
    }
    
    func createAppleIDButton() {
        let appleButton = ASAuthorizationAppleIDButton()
        view.addSubview(appleButton)
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        appleButton.topAnchor.constraint(equalTo: googleLoginButton.bottomAnchor, constant: 10).isActive = true
        appleButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 110).isActive = true
        appleButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -114).isActive = true
        appleButton.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)
    }
    
    @available(iOS 13, *)
    @objc
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
            
        }
        return result
    }



    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                              rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if (error != nil) {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error!.localizedDescription)
                    return
                }
                // User is signed in to Firebase with Apple.
                // ...
                self.transitionToHome(userUID: Auth.auth().currentUser!.uid)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error)
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    /*
     Google Sign In [START]
     */
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            print("")
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error)
                return
            }
            self.transitionToHome(userUID: Auth.auth().currentUser!.uid)
        }
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
      -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    /*
    Google Sign In [END]
    */
    
    func transitionToHome(userUID: String) {
        
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as! HomeViewController
        homeViewController.userUID = userUID
        self.navigationController?.isNavigationBarHidden = true;
        self.navigationController?.pushViewController(homeViewController, animated: false)
        
    }
}
