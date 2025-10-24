//
//  SceneDelegate.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/16/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let httpClient = HttpClient(session: .shared)
    private lazy var movieService = MovieService(client: httpClient)
    private lazy var userService = UserService(client: httpClient)
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
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
                    }
                    if let genre = nav.topViewController as? GenreViewController {
                        genre.movieService = movieService
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
    
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

