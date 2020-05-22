//
//  ResetPasswordViewController.swift
//  Login
//
//  Created by Elvis Alvarado on 2/7/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//

import UIKit
import FirebaseAuth
import ProgressHUD

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGradientBackground()
        tapViewToDismissKeyboard()
        roundButtonCorners()
    }
    
    func roundButtonCorners() {
        resetButton.layer.cornerRadius = 5
    }
    
    func tapViewToDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
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
    
    func validateField() -> String? {
        
        // Check that all fields are filled in
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        
        return nil
    }
    
    @IBAction func resetPasswordTapped(_ sender: Any) {
        
        let error = validateField()
        
        if error != nil {
            showError(error!)
        } else {
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().sendPasswordReset(withEmail: email) { (err) in
                if err != nil {
                    self.showError("Please use a valid email.")
                }
            }
            ProgressHUD.showSuccess("We have just sent you a password reset email. Please check your email and follow the instructions to reset your password.")
            self.transitionToFirstView()
        }
        
    }
    
    func transitionToFirstView() {
        navigationController?.popViewController(animated: true)
    }
    
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }

}
