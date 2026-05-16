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

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        configureAuthAppearance()
        setupUI()
    }

    private func setupUI() {
        view.subviews.forEach { $0.removeFromSuperview() }
        AuthTheme.addDismissKeyboardGesture(to: view)

        let header = AuthTheme.makeHeaderStack(
            title: "MovieTracker",
            subtitle: "Track films you love. Build your watchlist."
        )

        let loginButton = makeActionButton(title: "Log In", isPrimary: true)
        loginButton.addTarget(self, action: #selector(loginPressed), for: .touchUpInside)

        let signUpButton = makeActionButton(title: "Create Account", isPrimary: false)
        signUpButton.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)

        let footer = AuthTheme.makeSubtitleLabel("Your personal cinema journal starts here.")

        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(header)
        contentStack.addArrangedSubview(loginButton)
        contentStack.addArrangedSubview(signUpButton)
        contentStack.addArrangedSubview(footer)
        contentStack.setCustomSpacing(36, after: header)
        contentStack.setCustomSpacing(12, after: loginButton)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 32),
            contentStack.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor,
                constant: AuthTheme.horizontalPadding
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor,
                constant: -AuthTheme.horizontalPadding
            ),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32)
        ])
    }

    private func makeActionButton(title: String, isPrimary: Bool) -> UIButton {
        let button = UIButton(type: .system)
        if isPrimary {
            AuthTheme.stylePrimaryButton(button, title: title)
        } else {
            AuthTheme.styleSecondaryButton(button, title: title)
        }
        return button
    }

    @objc private func loginPressed() {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginVC.userService = userService
        loginVC.onLoginSuccess = onLoginSuccess
        navigationController?.pushViewController(loginVC, animated: true)
    }

    @objc private func signUpPressed() {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        vc.userService = userService
        vc.onSuccess = onLoginSuccess
        navigationController?.pushViewController(vc, animated: true)
    }
}
