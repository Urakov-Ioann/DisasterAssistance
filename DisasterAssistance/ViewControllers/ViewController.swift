//
//  ViewController.swift
//  DisasterAssistance
//
//  Created by Иоанн Ураков on 20.04.2024.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func loginButtonAction(_ sender: Any) {
        let vc =  TabBarController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
                                                      
    @IBAction func injuredButtonAction(_ sender: Any) {
        let vc = InjuredTabBarController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
