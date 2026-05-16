//
//  LoginViewController.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/24/25.
//

import UIKit

class LoginViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    var userService: UserService?
    var onLoginSuccess: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        configureAuthAppearance()
        setupUI()
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }

    @objc private func loginButtonTapped() {
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            presentAuthAlert(title: "Missing info", message: "Enter your username and password.")
            return
        }

        setLoading(true)
        Task {
            var isSuccessful = false
            _ = try? await userService?.login(
                credentials: LoginRequest(
                    grantType: "password",
                    username: username,
                    password: password
                )
            ) { result in
                switch result {
                case .success:
                    isSuccessful = true
                case .failure(let error):
                    Task { @MainActor in
                        self.setLoading(false)
                        self.presentAuthAlert(
                            title: "Log in failed",
                            message: error.failureReason ?? error.localizedDescription
                        )
                    }
                }
            }

            await MainActor.run {
                self.setLoading(false)
                if isSuccessful {
                    self.onLoginSuccess?()
                }
            }
        }
    }

    private func setupUI() {
        AuthTheme.addDismissKeyboardGesture(to: view)

        let header = AuthTheme.makeHeaderStack(
            title: "Welcome back",
            subtitle: "Sign in to pick up where you left off."
        )

        AuthTheme.styleTextField(usernameTextField, placeholder: "Username")
        usernameTextField.returnKeyType = .next
        AuthTheme.styleTextField(passwordTextField, placeholder: "Password", isSecure: true)
        passwordTextField.returnKeyType = .done
        AuthTheme.stylePrimaryButton(loginButton, title: "Log In")

        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true

        let fieldsStack = UIStackView(arrangedSubviews: [usernameTextField, passwordTextField])
        fieldsStack.axis = .vertical
        fieldsStack.spacing = 14

        let buttonStack = UIStackView(arrangedSubviews: [loginButton, activityIndicator])
        buttonStack.axis = .vertical
        buttonStack.alignment = .center
        buttonStack.spacing = 12

        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(header)
        contentStack.addArrangedSubview(fieldsStack)
        contentStack.addArrangedSubview(buttonStack)
        contentStack.setCustomSpacing(28, after: header)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor,
                constant: AuthTheme.horizontalPadding
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor,
                constant: -AuthTheme.horizontalPadding
            ),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),

            loginButton.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor)
        ])
    }

    private func setLoading(_ isLoading: Bool) {
        loginButton.isEnabled = !isLoading
        usernameTextField.isEnabled = !isLoading
        passwordTextField.isEnabled = !isLoading
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    private func presentAuthAlert(title: String, message: String) {
        let dialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .default))
        present(dialog, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            loginButtonTapped()
        }
        return true
    }
}
