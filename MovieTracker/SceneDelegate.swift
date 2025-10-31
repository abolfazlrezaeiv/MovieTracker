//
//  SceneDelegate.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/16/25.
//

import UIKit
import SwiftData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let httpClient = HttpClient(session: .shared)
    private lazy var movieService = MovieService(client: httpClient)
    private lazy var userService = UserService(client: httpClient)
    
    private var modelContainer: ModelContainer?
    private var modelContext: ModelContext?
    
    fileprivate func setupSwiftData() {
        do {
            let container = try ModelContainer(for: FavoriteMovie.self)
            self.modelContainer = container
            self.modelContext = ModelContext(container)
            
        } catch {
            fatalError("Failed to initialize SwiftData: \(error)")
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        setupSwiftData()
        
        if userService.isLoggedIn() {
            window?.rootViewController = makeMainTabBarController()
        } else {
            window?.rootViewController = makeAuthController()
        }
        window?.makeKeyAndVisible()
    }
    
    private func makeMainTabBarController() -> UITabBarController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBar = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
        
        if let vcs = tabBar.viewControllers {
            for vc in vcs {
                if let nav = vc as? UINavigationController {
                    if let home = nav.topViewController as? HomeViewController {
                        home.movieService = movieService
                        home.modelContext = modelContext
                    }
                    if let genre = nav.topViewController as? GenreViewController {
                        genre.movieService = movieService
                    }
                    if let profile = nav.topViewController as? ProfileViewController {
                        profile.userService = userService
                        profile.onLogoutSucces = { [weak self] in
                            guard let self else { return }
                            let auth = self.makeAuthController()
                            self.transitionRoot(to: auth)
                        }
                    }
                }
               
            }
        }
        return tabBar
    }
    
    private func makeAuthController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let auth = storyboard.instantiateViewController(withIdentifier: "AuthView") as! AuthViewController
        auth.userService = userService
        // Provide a callback that SceneDelegate can use to switch roots after login
        auth.onLoginSuccess = { [weak self] in
            guard let self else { return }
            let main = self.makeMainTabBarController()
            self.transitionRoot(to: main)
        }
        return UINavigationController(rootViewController: auth)
    }
    
    private func transitionRoot(to viewController: UIViewController) {
        guard let window = window else { return }
        // Optional animated crossfade
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = viewController
        })
    }
    
    
    func sceneDidDisconnect(_ scene: UIScene) { }
    func sceneDidBecomeActive(_ scene: UIScene) { }
    func sceneWillResignActive(_ scene: UIScene) { }
    func sceneWillEnterForeground(_ scene: UIScene) { }
    func sceneDidEnterBackground(_ scene: UIScene) {
        // If you want, you can save SwiftData context here:
         try? modelContext?.save()
    }
}
