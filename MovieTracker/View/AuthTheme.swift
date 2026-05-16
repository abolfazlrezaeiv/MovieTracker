import UIKit

enum AuthTheme {
    static let background = UIColor(red: 0.05, green: 0.05, blue: 0.07, alpha: 1)
    static let surface = UIColor(red: 0.11, green: 0.11, blue: 0.14, alpha: 1)
    static let accent = UIColor(red: 0.90, green: 0.11, blue: 0.14, alpha: 1)
    static let accentMuted = UIColor(red: 0.90, green: 0.11, blue: 0.14, alpha: 0.18)
    static let textPrimary = UIColor.white
    static let textSecondary = UIColor(white: 1, alpha: 0.62)
    static let fieldBorder = UIColor(white: 1, alpha: 0.12)

    static let cornerRadius: CGFloat = 14
    static let fieldHeight: CGFloat = 52
    static let buttonHeight: CGFloat = 52
    static let horizontalPadding: CGFloat = 24

    static func applyBackground(to view: UIView) {
        view.backgroundColor = background
    }

    static func configureNavigationBar(_ navigationBar: UINavigationBar?) {
        guard let navigationBar else { return }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: textPrimary]
        appearance.largeTitleTextAttributes = [.foregroundColor: textPrimary]
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.tintColor = accent
    }

    static func makeIconView(systemName: String = "film.stack.fill", size: CGFloat = 44) -> UIImageView {
        let config = UIImage.SymbolConfiguration(pointSize: size, weight: .medium)
        let imageView = UIImageView(image: UIImage(systemName: systemName, withConfiguration: config))
        imageView.tintColor = accent
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: size + 8),
            imageView.heightAnchor.constraint(equalToConstant: size + 8)
        ])
        return imageView
    }

    static func makeTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = textPrimary
        label.numberOfLines = 0
        return label
    }

    static func makeSubtitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = textSecondary
        label.numberOfLines = 0
        return label
    }

    static func makeHeaderStack(title: String, subtitle: String) -> UIStackView {
        let icon = makeIconView()
        let titleLabel = makeTitleLabel(title)
        let subtitleLabel = makeSubtitleLabel(subtitle)
        let stack = UIStackView(arrangedSubviews: [icon, titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .leading
        stack.setCustomSpacing(20, after: icon)
        return stack
    }

    static func styleTextField(
        _ textField: UITextField,
        placeholder: String,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default
    ) {
        textField.text = nil
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecure
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.textColor = textPrimary
        textField.tintColor = accent
        textField.backgroundColor = surface
        textField.layer.cornerRadius = cornerRadius
        textField.layer.borderWidth = 1
        textField.layer.borderColor = fieldBorder.cgColor
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true

        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: fieldHeight))
        textField.leftView = padding
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: fieldHeight))
        textField.rightViewMode = .always

        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: textSecondary]
        )
    }

    static func stylePrimaryButton(_ button: UIButton, title: String) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = accent
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        button.configuration = config
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
    }

    static func styleSecondaryButton(_ button: UIButton, title: String) {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = textPrimary
        config.background.backgroundColor = surface
        config.background.cornerRadius = cornerRadius
        config.background.strokeColor = fieldBorder
        config.background.strokeWidth = 1
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        button.configuration = config
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
    }

    static func addDismissKeyboardGesture(to view: UIView) {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Home

    static func styleSearchBar(_ searchBar: UISearchBar) {
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search movies..."
        searchBar.barTintColor = .clear
        searchBar.backgroundImage = UIImage()
        searchBar.tintColor = accent

        let field = searchBar.searchTextField
        field.backgroundColor = surface
        field.textColor = textPrimary
        field.tintColor = accent
        field.layer.cornerRadius = cornerRadius
        field.layer.masksToBounds = true
        field.font = .systemFont(ofSize: 16, weight: .regular)
        field.attributedPlaceholder = NSAttributedString(
            string: "Search movies...",
            attributes: [.foregroundColor: textSecondary]
        )
    }

    static func styleGenresCollectionView(_ collectionView: UICollectionView) {
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 20, right: 0)
    }

    static func iconName(forGenre name: String) -> String {
        let genre = name.lowercased()
        if genre.contains("action") { return "bolt.fill" }
        if genre.contains("comedy") { return "face.smiling.fill" }
        if genre.contains("drama") { return "theatermasks.fill" }
        if genre.contains("horror") { return "moon.fill" }
        if genre.contains("romance") { return "heart.fill" }
        if genre.contains("sci") { return "sparkles" }
        if genre.contains("fantasy") { return "wand.and.stars" }
        if genre.contains("thriller") { return "eye.fill" }
        if genre.contains("animation") { return "paintbrush.fill" }
        if genre.contains("documentary") { return "camera.fill" }
        if genre.contains("crime") { return "hand.raised.fill" }
        if genre.contains("adventure") { return "map.fill" }
        if genre.contains("family") { return "person.3.fill" }
        if genre.contains("mystery") { return "questionmark.circle.fill" }
        return "film.fill"
    }

    static func styleMovieListTableView(_ tableView: UITableView) {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 20, right: 0)
        tableView.keyboardDismissMode = .onDrag
    }

    static func configureTabBar(_ tabBar: UITabBar?) {
        guard let tabBar else { return }
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = surface
        appearance.stackedLayoutAppearance.normal.iconColor = textSecondary
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: textSecondary
        ]
        appearance.stackedLayoutAppearance.selected.iconColor = accent
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: accent
        ]
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = accent
        tabBar.unselectedItemTintColor = textSecondary
    }

    static func makeProfileHeader(username: String?) -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 168))
        container.backgroundColor = .clear

        let card = UIView()
        card.backgroundColor = surface
        card.layer.cornerRadius = 20
        card.layer.borderWidth = 1
        card.layer.borderColor = fieldBorder.cgColor
        card.translatesAutoresizingMaskIntoConstraints = false

        let avatarContainer = UIView()
        avatarContainer.backgroundColor = accentMuted
        avatarContainer.layer.cornerRadius = 36
        avatarContainer.translatesAutoresizingMaskIntoConstraints = false

        let avatarIcon = UIImageView(image: UIImage(
            systemName: "person.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        ))
        avatarIcon.tintColor = accent
        avatarIcon.translatesAutoresizingMaskIntoConstraints = false

        let nameLabel = UILabel()
        nameLabel.text = username ?? "MovieTracker User"
        nameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        nameLabel.textColor = textPrimary
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Your cinema profile"
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = textSecondary
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(card)
        card.addSubview(avatarContainer)
        avatarContainer.addSubview(avatarIcon)
        card.addSubview(nameLabel)
        card.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: horizontalPadding),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -horizontalPadding),
            card.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),

            avatarContainer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            avatarContainer.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 72),
            avatarContainer.heightAnchor.constraint(equalToConstant: 72),

            avatarIcon.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarIcon.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 28),

            subtitleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4)
        ])

        return container
    }

    static func makeEmptyStateView(
        icon: String,
        title: String,
        message: String
    ) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let iconView = UIImageView(image: UIImage(
            systemName: icon,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
        ))
        iconView.tintColor = textSecondary
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = .systemFont(ofSize: 15, weight: .regular)
        messageLabel.textColor = textSecondary
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel, messageLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -32)
        ])

        return container
    }

    static func makeListHeaderView(title: String, count: Int) -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 52))
        let label = UILabel()
        let countText = count == 1 ? "1 movie saved" : "\(count) movies saved"
        label.text = "\(title) · \(countText)"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: horizontalPadding),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -horizontalPadding),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])
        return container
    }

    static func styleProfileTableView(_ tableView: UITableView) {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
    }

    static func makeLoadingFooter(width: CGFloat) -> UIView {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 56))
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = accent
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        footer.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: footer.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: footer.centerYAnchor)
        ])
        return footer
    }
}

extension UIViewController {
    func configureAuthAppearance() {
        AuthTheme.applyBackground(to: view)
        AuthTheme.configureNavigationBar(navigationController?.navigationBar)
        navigationItem.backButtonDisplayMode = .minimal
    }

    func configureHomeAppearance(title: String = "Discover") {
        AuthTheme.applyBackground(to: view)
        AuthTheme.configureNavigationBar(navigationController?.navigationBar)
        AuthTheme.configureTabBar(tabBarController?.tabBar)
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.largeTitleDisplayMode = .always
        self.title = title
    }
}
