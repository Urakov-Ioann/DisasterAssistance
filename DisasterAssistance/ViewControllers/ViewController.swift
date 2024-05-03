//
//  ViewController.swift
//  DisasterAssistance
//
//  Created by Иоанн Ураков on 20.04.2024.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var injuredButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        injuredButton.layer.cornerRadius = 12
        injuredButton.layer.borderColor = UIColor.black.cgColor
        injuredButton.layer.borderWidth = 1
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
