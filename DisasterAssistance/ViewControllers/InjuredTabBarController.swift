//
//  InjuredTabBarController.swift
//  DisasterAssistance
//
//  Created by Иоанн Ураков on 20.04.2024.
//

import UIKit

class InjuredTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
}

private extension InjuredTabBarController {
    func setupTabBarController() {
        let story = UIStoryboard(name: "Main", bundle:nil)
        
        let injuredViewController = story.instantiateViewController(withIdentifier: "InjuredVC") as! InjuredViewController
        let profileViewController = story.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileViewController
        
        let navInjuredViewController = UINavigationController(rootViewController: injuredViewController)
        let navProfileViewController = UINavigationController(rootViewController: profileViewController)
        
        navInjuredViewController.tabBarItem.title = "Экран пострадавшего"
        navInjuredViewController.tabBarItem.image = UIImage(systemName: "figure.wave")
        navProfileViewController.tabBarItem.title = "Профиль"
        navProfileViewController.tabBarItem.image = UIImage(systemName: "person")
        
        tabBar.tintColor = .black
        
        viewControllers = [
            navInjuredViewController,
            navProfileViewController
        ]
    }
}
