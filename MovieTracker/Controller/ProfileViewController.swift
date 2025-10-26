//
//  ProfileViewController.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/26/25.
//
import UIKit

class ProfileViewController: UIViewController {
    var tableView: UITableView!
    
    var userService: UserService?
    var options : [String] = ["My List", "Sign Out"]
    var onLogoutSucces: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)

        setupUI()

    }
    
    func setupUI() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = options[indexPath.row]
        return cell!
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        print(indexPath.row)
        if indexPath.row == 1 {
            userService?.logout(completion:  {
                self.onLogoutSucces?()
            })
        }
    }
}
