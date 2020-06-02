//
//  LoginViewController.swift
//  Login
//
//  Created by Elvis Alvarado on 1/29/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func validateFields() -> String? {
        
        // Check that all fields are filled in
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        
        return nil
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        // Validate text fields
        let error =  validateFields()
        
        if error != nil {
            // show error if something went wrong when filling out text fields
            showError(error!)
        } else {
            // Take our whitespaces and newlines the fields
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Signing in as user
            Auth.auth().signIn(withEmail: email, password: password) { (result, err) in
                if err != nil {
                    self.showError("Please use a valid email or password.")
                } else {
                    self.transitionToHome(userUID: Auth.auth().currentUser!.uid)
                }
            }
        }
    }
    
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToHome(userUID: String) {
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as! HomeViewController
        homeViewController.userUID = userUID
        self.navigationController?.isNavigationBarHidden = true;
        self.navigationController?.pushViewController(homeViewController, animated: false)
        
    }
    
}
