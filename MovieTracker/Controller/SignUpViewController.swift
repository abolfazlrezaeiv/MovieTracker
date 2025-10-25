//
//  SignUpViewController.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/24/25.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var userService: UserService?
    var onSuccess: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    @IBAction func onSignupPressed(_ sender: UIButton) {
        Task {
            if let username = usernameField.text, let password = passwordField.text {
                var isSigningUp: Bool = false
                _ = await userService?
                    .register(
                        user: RegisterRequest(
                            username: username,
                            passowrd: password,
                            email: username,
                        )
                    ) { result in
                        switch result {
                        case .success(_):
                            isSigningUp = true
                        case .failure(let error):
                            isSigningUp = false

                            Task {@MainActor in
                                let warningDialog = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                                warningDialog.addAction(action)
                                self.present(warningDialog, animated: true, completion: nil)
                            }
                           
                        }
                        
                    }
                if isSigningUp {
                    await MainActor.run {
                        self.onSuccess?()
                    }
                }
            }
        }
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            _ = passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            _ = view.endEditing(true)
        } else {
             _ = view.endEditing(true)
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        true
    }
}
