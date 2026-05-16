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
        super.viewDidLoad()
        
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginVC.userService = self.userService
        loginVC.onLoginSuccess = onLoginSuccess
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        vc.userService = self.userService
        vc.onSuccess = onLoginSuccess
        navigationController?.pushViewController(vc, animated: true)
    }
}
