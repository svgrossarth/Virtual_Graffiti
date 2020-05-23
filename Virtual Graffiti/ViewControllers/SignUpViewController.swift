//
//  SignUpViewController.swift
//  Login
//
//  Created by Elvis Alvarado on 1/29/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGradientBackground()
        tapViewToDismissKeyboard()
        roundButtonCorners()
    }
    
    func roundButtonCorners() {
        signUpButton.layer.cornerRadius = 5
    }
    
    func tapViewToDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func createGradientBackground() {
        let topColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 0.0/255.0, green: 40.0/255.0, blue: 85.0/255.0, alpha: 1.0).cgColor

        let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.colors = [topColor, bottomColor]
        gradient.locations = [0.0, 1.0]
        
        self.view.layer.insertSublayer(gradient, at: 0)
    }
    
    func validateFields() -> String? {
        
        // Check that all fields are filled in
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        
        return nil
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        
        // Validate the fields
        let error =  validateFields()
        
        if error != nil {
            // show error if something went wrong when filling out text fields
            showError(error!)
        } else {
                        
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            
            // Create the users
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                // Check for errors
                if err != nil {
                    // There was an error creating the user
                    self.showError("Error creating user.")
                } else {
                    self.transitionToHome(userUID: Auth.auth().currentUser!.uid)
                }
            }
            
            // Transition to the home screen
        }
    }
    
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToHome(userUID: String) {
        
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as! HomeViewController
        homeViewController.userUID = userUID
        homeViewController.firstTime = true
        self.navigationController?.isNavigationBarHidden = true;
        self.navigationController?.pushViewController(homeViewController, animated: false)
        
    }
    
}
