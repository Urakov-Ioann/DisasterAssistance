//
//  TabBarController.swift
//  DisasterAssistance
//
//  Created by Иоанн Ураков on 20.04.2024.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
}

private extension TabBarController {
    func setupTabBarController() {
        let story = UIStoryboard(name: "Main", bundle:nil)
        
        let rescuerViewController = story.instantiateViewController(withIdentifier: "RescuerVC") as! RescuerViewController
        let profileViewController = story.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileViewController
        
        let navRescViewController = UINavigationController(rootViewController: rescuerViewController)
        let navProfileViewController = UINavigationController(rootViewController: profileViewController)
        
        navRescViewController.tabBarItem.title = "Rescuer"
        navProfileViewController.tabBarItem.title = "Profile"
        
        viewControllers = [
            navRescViewController,
            navProfileViewController
        ]
    }
}
