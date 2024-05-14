//
//  AuthViewController.swift
//  DisasterAssistance
//
//  Created by Иоанн Ураков on 20.04.2024.
//

import UIKit

class AuthViewController: UIViewController {

    @IBOutlet weak var injuredButton: UIButton!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    private var disasterTypePicker: UIPickerView = UIPickerView()
    
    private let authService: AuthServiceProtocol = AuthService()
    private let alertManager: AlertManagerProtocol = AlertManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        injuredButton.layer.cornerRadius = 12
        injuredButton.layer.borderColor = UIColor.black.cgColor
        injuredButton.layer.borderWidth = 1
        passwordTextField.isSecureTextEntry = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc 
    func tapGesture() {
        loginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }


    @IBAction func loginButtonAction(_ sender: Any) {
        let userRequest = LoginUserRequest(
            email: loginTextField.text ?? "",
            password: passwordTextField.text ?? ""
        )
        
        authService.loginUser(with: userRequest) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                let action = ActionModel(
                    title: "Понятно",
                    style: .destructive,
                    actionBlock: nil)
                let alertModel = AlertModel(
                    title: "Ошибка",
                    message: "Неправильный логин или пароль",
                    preferredStyle: .alert,
                    actions: [action])
                self.alertManager.showAlert(from: self, alertModel: alertModel)
                return
            }
            let vc =  TabBarController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
                                                      
    @IBAction func injuredButtonAction(_ sender: Any) {
        let vc = InjuredTabBarController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
