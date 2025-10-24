//
//  Untitled.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/24/25.
//

import UIKit

class LoginViewController: UIViewController {
    var usernameTextField: UITextField!
    var passwordTextField: UITextField!
    var loginButton: UIButton!
    var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        usernameTextField.delegate = self
        passwordTextField.delegate = self

        
    }
    
    func setupUI() {
        usernameTextField = UITextField()
        usernameTextField.placeholder = "Username"
        usernameTextField.layer.borderColor = UIColor.systemGreen.cgColor
        usernameTextField.layer.cornerRadius = 12
        usernameTextField.layer.borderWidth = 1.5
        usernameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        usernameTextField.leftViewMode = .always
        

        passwordTextField = UITextField()
        passwordTextField.placeholder = "Password"
        passwordTextField.layer.borderColor = UIColor.systemGreen.cgColor
        passwordTextField.layer.cornerRadius = 12
        passwordTextField.layer.borderWidth = 1.5
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        passwordTextField.leftViewMode = .always

        
        loginButton = UIButton(type: .system)
        loginButton.setTitle("Log In", for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 12
        
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fill
        
        stackView.addArrangedSubview(usernameTextField)
        stackView.addArrangedSubview(passwordTextField)
        
        view.addSubview(stackView)
        view.addSubview(loginButton)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        

        
        NSLayoutConstraint.activate([
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 68),
            
            stackView.leadingAnchor
                .constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor
                .constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            
            passwordTextField.heightAnchor.constraint(equalToConstant: 68),
            usernameTextField.heightAnchor.constraint(equalToConstant: 68),
        ])
        
    }
    
}


extension LoginViewController: UITextFieldDelegate {
    
}
