//
//  ProfileViewController.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/26/25.
//
import UIKit
import SwiftData

class ProfileViewController: UIViewController {
    private var tableView: UITableView!
    private var favoriteCount = 0

    var userService: UserService?
    var movieService: MovieService?
    var modelContext: ModelContext!
    var onLogoutSucces: (() -> Void)?

    private enum MenuRow: Int, CaseIterable {
        case myList
        case signOut
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHomeAppearance(title: "Profile")
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AuthTheme.configureTabBar(tabBarController?.tabBar)
        refreshFavoriteCount()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let header = tableView.tableHeaderView else { return }
        let width = tableView.bounds.width
        guard header.frame.width != width else { return }
        header.frame.size.width = width
        let height = header.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        header.frame.size.height = height
        tableView.tableHeaderView = header
    }

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        AuthTheme.styleProfileTableView(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ProfileMenuCell.self, forCellReuseIdentifier: ProfileMenuCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 84
        tableView.translatesAutoresizingMaskIntoConstraints = false

        let username = userService?.getUser()
        tableView.tableHeaderView = AuthTheme.makeProfileHeader(username: username)

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func refreshFavoriteCount() {
        do {
            let descriptor = FetchDescriptor<FavoriteMovie>()
            favoriteCount = try modelContext.fetchCount(descriptor)
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        MenuRow.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ProfileMenuCell.reuseIdentifier,
            for: indexPath
        ) as! ProfileMenuCell

        guard let row = MenuRow(rawValue: indexPath.row) else { return cell }

        switch row {
        case .myList:
            let subtitle = favoriteCount == 0
                ? "No saved movies yet"
                : (favoriteCount == 1 ? "1 saved movie" : "\(favoriteCount) saved movies")
            cell.configure(
                icon: "heart.fill",
                title: "My List",
                subtitle: subtitle
            )
        case .signOut:
            cell.configure(
                icon: "rectangle.portrait.and.arrow.right",
                title: "Sign Out",
                subtitle: "Log out of your account",
                isDestructive: true
            )
        }

        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = MenuRow(rawValue: indexPath.row) else { return }

        switch row {
        case .myList:
            let favoritesVC = FavoriteMoviesViewController()
            favoritesVC.modelContext = modelContext
            favoritesVC.movieService = movieService
            navigationController?.pushViewController(favoritesVC, animated: true)
        case .signOut:
            presentSignOutConfirmation()
        }
    }

    private func presentSignOutConfirmation() {
        let alert = UIAlertController(
            title: "Sign out?",
            message: "You will need to log in again to access your account.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            self?.userService?.logout {
                self?.onLogoutSucces?()
            }
        })
        present(alert, animated: true)
    }
}
