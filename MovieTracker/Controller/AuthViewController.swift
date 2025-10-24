//
//  AuthViewController.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/24/25.
//

import UIKit

class AuthViewController: UIViewController {
    var userService: UserService?
    var onLoginSuccess: (() -> Void)?
    
    override func viewDidLoad() {
        
    }
    @IBAction func loginPressed(_ sender: UIButton) {
        let loginVC = LoginViewController()
        loginVC.userService = self.userService
        loginVC.onloginSuccess = onLoginSuccess
        navigationController?.pushViewController(loginVC, animated: true)
    }
    @IBAction func signUpPressed(_ sender: UIButton) {
    }
}
