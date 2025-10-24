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
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func onSignupPressed(_ sender: UIButton) {
    }
}
