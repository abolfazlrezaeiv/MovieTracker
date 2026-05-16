//
//  SignUpViewController.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/24/25.
//

import UIKit

class SignUpViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let signUpButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    var userService: UserService?
    var onSuccess: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign Up"
        configureAuthAppearance()
        setupUI()
        signUpButton.addTarget(self, action: #selector(onSignupPressed), for: .touchUpInside)
        usernameField.delegate = self
        passwordField.delegate = self
    }

    @objc private func onSignupPressed() {
        guard let username = usernameField.text, !username.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            presentAuthAlert(title: "Missing info", message: "Enter a username and password.")
            return
        }

        setLoading(true)
        Task {
            guard let userService else {
                await MainActor.run { self.setLoading(false) }
                return
            }

            let registered = await userService.register(
                user: RegisterRequest(
                    username: username,
                    passowrd: password,
                    email: username
                )
            ) { result in
                if case .failure(let error) = result {
                    Task { @MainActor in
                        self.setLoading(false)
                        self.presentAuthAlert(
                            title: "Sign up failed",
                            message: error.localizedDescription
                        )
                    }
                }
            }

            guard registered != nil else {
                await MainActor.run { self.setLoading(false) }
                return
            }

            var loggedIn = false
            _ = try? await userService.login(
                credentials: LoginRequest(
                    grantType: "password",
                    username: username,
                    password: password
                )
            ) { result in
                if case .success = result {
                    loggedIn = true
                }
            }

            await MainActor.run {
                self.setLoading(false)
                if loggedIn {
                    self.onSuccess?()
                } else {
                    self.presentAuthAlert(
                        title: "Account created",
                        message: "Please log in with your new account."
                    )
                }
            }
        }
    }

    private func setupUI() {
        view.subviews.forEach { $0.removeFromSuperview() }
        AuthTheme.addDismissKeyboardGesture(to: view)

        let header = AuthTheme.makeHeaderStack(
            title: "Create account",
            subtitle: "Join MovieTracker and start building your list."
        )

        AuthTheme.styleTextField(usernameField, placeholder: "Username")
        usernameField.returnKeyType = .next
        AuthTheme.styleTextField(passwordField, placeholder: "Password", isSecure: true)
        passwordField.returnKeyType = .done
        AuthTheme.stylePrimaryButton(signUpButton, title: "Sign Up")

        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true

        let fieldsStack = UIStackView(arrangedSubviews: [usernameField, passwordField])
        fieldsStack.axis = .vertical
        fieldsStack.spacing = 14

        let buttonStack = UIStackView(arrangedSubviews: [signUpButton, activityIndicator])
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

            signUpButton.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor)
        ])
    }

    private func setLoading(_ isLoading: Bool) {
        signUpButton.isEnabled = !isLoading
        usernameField.isEnabled = !isLoading
        passwordField.isEnabled = !isLoading
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

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === usernameField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            onSignupPressed()
        }
        return true
    }
}
