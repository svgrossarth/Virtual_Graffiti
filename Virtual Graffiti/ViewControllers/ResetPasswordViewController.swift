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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        
        guard let loginViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.loginViewController) as? LoginViewController else { return }
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }

}
