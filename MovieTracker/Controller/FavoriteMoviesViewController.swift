//
//  FavoriteMoviesViewController.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 11/16/25.
//
import UIKit

class FavoriteMoviesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Favorite movies"
    }
}
